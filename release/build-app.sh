#!/bin/bash
#
# Unified Build Script
# --------------------
# Automates the build process for the Music Control app across all platforms.
#
# Usage:
#   ./build-app.sh --android [--deploy]
#   ./build-app.sh --ios [--deploy | --store]
#   ./build-app.sh --linux|--linux-remote
#   ./build-app.sh --macos [--deploy]
#
# Requirements:
#   - 'flutter' must be in PATH variable
#   - Call 'git fetch' in the Flutter directory so that the local Flutter
#     repository gets all the new info from Github
#   - Platform specific requirements:
#     -- Android: 'adb' (Android Debug Bridge) is required for the --deploy flag
#     -- iOS: 'ios-deploy' (via brew) is required for the --deploy flag:
#        brew install ios-deploy
#     -- Linux: Install additional packages:
#        dnf install clang cmake ninja-build gtk3-devel xz-devel
#     -- macOS: 'create-dmg' (via brew) is required to generate the installer image:
#        brew install create-dmg
#        If "Not authorized to send Apple events to Finder" appears:
#        tccutil reset AppleEvents com.google.android.studio
#   - Requirement for the remote build:
#     -- SSH password-less access to the remote host (setup in ~/.ssh/config recommended).
#     -- The remote host must have the project repository checked out.
#     -- The 'ONPC_HOME' environment variable must be set on the remote host, pointing
#        to the project root.

# Exit immediately if any command exits with a non-zero status
set -e

# Get the directory where this script is located
ONPC_RELEASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REMOTE_HOST_Linux="pm-dev-fedora"

# Shared logic for preparing the Flutter build environment.
# Usage:
#   prepare-build <FLUTTER_VERSION> <APP_SUFFIX> <PLATFORM_TYPE>
prepare-build() {

    # Check arguments
    if [ "$#" -lt 3 ]; then
        echo "Error: prepare-build requires at least 3 arguments: <FLUTTER_VERSION> <APP_SUFFIX> <PLATFORM_TYPE>"
        exit 1
    fi
    TARGET_FLUTTER_VER="$1"
    TARGET_SUFFIX="$2"
    TARGET_PLATFORM="$3"

    # Common input parameters
    DEPLOY_TO_DEVICE=false
    shift 3
    for arg in "$@"
    do
        if [ "$arg" == "--deploy" ]; then
            DEPLOY_TO_DEVICE=true
        fi
    done

    # Navigate to release dir to ensure relative paths work
    cd "${ONPC_RELEASE_DIR}" || exit 1
    ONPC_PROJECT_ROOT="$(cd .. && pwd)"

    # Setup Flutter Environment
    FLUTTER_BIN=$(which flutter)
    if [ -z "$FLUTTER_BIN" ]; then
        echo "Error: 'flutter' command not found in PATH."
        exit 1
    fi
    ONPC_FLUTTER_PATH="$(dirname "$(dirname "$FLUTTER_BIN")")"

    echo "Setting up Flutter ${TARGET_FLUTTER_VER}..."
    cd "${ONPC_FLUTTER_PATH}" || exit
    git checkout -f "${TARGET_FLUTTER_VER}"
    export FLUTTER_GIT_URL="https://github.com/flutter/flutter.git"

    # Setup the APP name with version
    cd "${ONPC_RELEASE_DIR}" || exit
    if [ ! -f "VERSION.txt" ]; then
        echo "Error: VERSION.txt not found in ${ONPC_RELEASE_DIR}"
        exit 1
    fi
    ONPC_APP_VER=$(cat VERSION.txt)
    ONPC_APP_NAME="MusicControl-v${ONPC_APP_VER}-${TARGET_SUFFIX}"

    # Remove previous build artifact
    rm -f "${ONPC_APP_NAME}"

    # Setup Project Files (Symlinks)
    echo "Preparing project files for ${TARGET_PLATFORM}..."
    cd "${ONPC_PROJECT_ROOT}" || exit
    flutter clean

    # Update pubspec.yaml
    rm -f "pubspec.yaml"
    ln -s "pubspec.yaml_${TARGET_PLATFORM}" "pubspec.yaml"

    # Update CompatUtils.dart
    rm -f "lib/utils/CompatUtils.dart"
    ln -s "CompatUtils.dart.${TARGET_PLATFORM}" "lib/utils/CompatUtils.dart"

    # Info & Clean
    echo "------------------------------------------------"
    echo "Starting build for: ${ONPC_APP_NAME}"
    echo "Flutter SDK: ${ONPC_FLUTTER_PATH}"
    echo "Project root: ${ONPC_PROJECT_ROOT}"
    echo "Release dir: ${ONPC_RELEASE_DIR}"
    echo "Target platform: ${TARGET_PLATFORM}"
    echo "Deploy to device: ${DEPLOY_TO_DEVICE}"
    echo "------------------------------------------------"

    flutter doctor

    set -o pipefail
    flutter pub get | grep -vE "^\+ |^- |available\)"
}

# Android Build Method
build-android() {
    # Call common preparation script
    prepare-build "3.29.0" "android.apk" "mobile" "$@"

    # Build
    echo "Building Android application..."
    flutter build apk --release

    GENERATED_APK=$(find build/app/outputs/flutter-apk -maxdepth 1 -name "app-release.apk" | head -n 1)
    if [ -f "$GENERATED_APK" ]; then
        mv "$GENERATED_APK" "${ONPC_RELEASE_DIR}/${ONPC_APP_NAME}"
        echo "✅ Success! APK available at: ${ONPC_RELEASE_DIR}/${ONPC_APP_NAME}"

        # Deploy if requested
        if [ "$DEPLOY_TO_DEVICE" = true ]; then
            if ! command -v adb &> /dev/null; then
                echo "❌ Error: 'adb' command not found. Cannot deploy."
                exit 1
            fi
            echo "Deploying to connected device..."
            adb install -r "${ONPC_RELEASE_DIR}/${ONPC_APP_NAME}"
            echo "Starting application..."
            adb shell am start -n "com.mkulesh.onpc.plus/com.mkulesh.onpc.plus.MainActivity"
        fi
    else
        echo "❌ Error: APK file was not generated."
        exit 1
    fi
}

# iOS Build Method
build-ios() {
    # Call common preparation script
    prepare-build "3.29.0" "ios.ipa" "mobile" "$@"

    # Check for input parameters
    BUILD_FOR_STORE=false
    for arg in "$@"
    do
        if [ "$arg" == "--store" ]; then
            BUILD_FOR_STORE=true
        fi
    done

    # Build
    if [ "$BUILD_FOR_STORE" = true ]; then
        echo "Building for Store (creating .app/.xcarchive)..."
        flutter build ios --release
    else
        echo "Building for Distribution/Ad-Hoc..."
        flutter build ipa --release --export-options-plist="${ONPC_RELEASE_DIR}/build-ios-options.plist"

        GENERATED_IPA=$(find build/ios/ipa -maxdepth 1 -name "*.ipa" | head -n 1)
        if [ -f "$GENERATED_IPA" ]; then
            mv "$GENERATED_IPA" "${ONPC_RELEASE_DIR}/${ONPC_APP_NAME}"
            echo "✅ Success! IPA available at: ${ONPC_RELEASE_DIR}/${ONPC_APP_NAME}"

            # Deploy if requested
            if [ "$DEPLOY_TO_DEVICE" = true ]; then
                if ! command -v ios-deploy &> /dev/null; then
                    echo "❌ Error: 'ios-deploy' not found. Please run: brew install ios-deploy"
                    exit 1
                fi
                echo "Deploying to connected device..."
                ios-deploy --bundle "${ONPC_RELEASE_DIR}/${ONPC_APP_NAME}" --no-wifi > /dev/null
            fi
        else
            echo "❌ Error: IPA file was not generated."
            exit 1
        fi
    fi
}

# Linux Build Method
build-linux() {
    # Call common preparation script
    prepare-build "3.29.0" "linux-x86_64.zip" "desktop" "$@"

    # Remove the old build
    ONPC_DIR_NAME="${ONPC_RELEASE_DIR}/${ONPC_APP_NAME%.*}"
    rm -rf "${ONPC_DIR_NAME}"

    # Build app
    flutter build linux --release

    # Check the generated application bundle
    APP_BUNDLE_PATH="build/linux/x64/release/bundle"
    APP_BUNDLE_NAME="${APP_BUNDLE_PATH}/Music-Control"
    if [ ! -d "${APP_BUNDLE_PATH}" ]; then
        echo "❌ Error: application bundle was not generated in ${APP_BUNDLE_PATH}"
        exit 1
    fi
    echo "✅ Found application bundle: ${APP_BUNDLE_NAME}"

    # Move the application bundle
    mv "${APP_BUNDLE_PATH}" "${ONPC_DIR_NAME}"
    ICON_SRC="${ONPC_DIR_NAME}/data/flutter_assets/lib/assets/app_icon.png"
    if [ -f "$ICON_SRC" ]; then
        cp "$ICON_SRC" "${ONPC_DIR_NAME}/Music-Control.png"
    else
        echo "⚠️ Warning: App Icon not found at $ICON_SRC"
    fi

    # Archive the new build
    cd "${ONPC_RELEASE_DIR}"
    zip -qr "${ONPC_APP_NAME}" "$(basename "${ONPC_DIR_NAME}")"

    # Check if the archive was actually created
    if [ ! -f "${ONPC_APP_NAME}" ]; then
        echo "❌ Error: archive ${ONPC_APP_NAME} was not generated."
        exit 1
    fi
    echo "✅ Archive generated successfully: ${ONPC_APP_NAME}"
}

# Linux Build Method on a remote host
build-linux-remote() {
    echo "🔍 Resolving remote configuration..."
    REMOTE_HOME=$(ssh "$REMOTE_HOST_Linux" 'echo $ONPC_HOME')
    if [ -z "$REMOTE_HOME" ]; then
        echo "❌ Error: ONPC_HOME environment variable is not set on $REMOTE_HOST_Linux or connection failed."
        exit 1
    fi

    # Execute commands on the remote host
    echo "🚀 Connecting to $REMOTE_HOST_Linux to start build..."
    ssh "$REMOTE_HOST_Linux" /bin/bash << 'EOF'
        # Stop on error
        set -e

        # Check if ONPC_HOME is set
        if [ -z "$ONPC_HOME" ]; then
            echo "❌ Error: ONPC_HOME environment variable is not set on remote host."
            exit 1
        fi

        echo "📂 Navigating to project root: $ONPC_HOME"
        cd "$ONPC_HOME" || { echo "❌ Directory not found"; exit 1; }

        # echo "🧹 Cleaning..."
        ./clean.sh

        echo "🔄 Updating source..."
        git fetch --all
        git reset --hard "@{u}"
        git clean -fd

        echo "🔨 Building..."
        release/build-app.sh --linux
EOF

    # Check if the SSH command succeeded
    if [ $? -eq 0 ]; then
        echo "✅ Remote build finished successfully."
    else
        echo "❌ Remote build failed."
        exit 1
    fi

    # Define the filename on the remote host
    echo "📦 Locating artifact on remote..."
    VERSION_FILE="$SCRIPT_DIR/VERSION.txt"
    if [ ! -f "$VERSION_FILE" ]; then
        echo "❌ Error: VERSION.txt not found locally at $VERSION_FILE"
        exit 1
    fi
    ONPC_APP_NAME="MusicControl-v$(cat "$VERSION_FILE")-linux-x86_64.zip"
    REMOTE_FULL_PATH="$REMOTE_HOME/release/$ONPC_APP_NAME"
    echo "   Remote archive: $REMOTE_FULL_PATH"

    # Copy the file back
    echo "📦 Copying archive from remote..."
    scp -p "$REMOTE_HOST_Linux:$REMOTE_FULL_PATH" "$SCRIPT_DIR"

    if [ $? -eq 0 ]; then
        echo "✅ Success! Archive copied to current directory."
    else
        echo "❌ SCP failed. Please check if the remote archive $REMOTE_FULL_PATH exists on the remote host $REMOTE_HOST_Linux"
    fi
}

# macOS Build Method
build-macos() {
    # Call common preparation script
    prepare-build "3.29.0" "macos.dmg" "desktop" "$@"

    # Build app
    echo "Building macOS application..."
    flutter build macos --release

    # Locate the generated .app bundle dynamically
    APP_BUNDLE_PATH=$(find build/macos/Build/Products/Release -maxdepth 1 -name "*.app" | head -n 1)
    if [ -z "$APP_BUNDLE_PATH" ]; then
        echo "❌ Error: .app bundle was not generated in build/macos/Build/Products/Release/"
        exit 1
    fi
    APP_BUNDLE_NAME=$(basename "$APP_BUNDLE_PATH")
    echo "✅ Found application bundle: ${APP_BUNDLE_NAME}"

    # Create DMG image
    rm -f "${ONPC_RELEASE_DIR}/${ONPC_APP_NAME}"
    echo "Creating DMG image..."
    if ! command -v create-dmg &> /dev/null; then
        echo "❌ Error: 'create-dmg' not found. Please run: brew install create-dmg"
        exit 1
    fi
    create-dmg \
      --volname "MusicControl-v${ONPC_APP_VER}" \
      --window-pos 200 120 \
      --window-size 800 400 \
      --icon-size 100 \
      --icon "${APP_BUNDLE_NAME}" 200 190 \
      --hide-extension "${APP_BUNDLE_NAME}" \
      --app-drop-link 600 185 \
      --hdiutil-quiet \
      "${ONPC_RELEASE_DIR}/${ONPC_APP_NAME}" \
      "${APP_BUNDLE_PATH}"

    echo "✅ Success! DMG available at: ${ONPC_RELEASE_DIR}/${ONPC_APP_NAME}"

    # Install if requested
    if [ "$DEPLOY_TO_DEVICE" = true ]; then
        echo "Installing application to /Applications..."

        # Mount the DMG
        # -noverify: Skip verification for speed
        # -mountpoint: Mount to a specific temporary path
        MOUNT_POINT="/tmp/MusicControl_Install"
        mkdir -p "$MOUNT_POINT"

        hdiutil attach "${ONPC_RELEASE_DIR}/${ONPC_APP_NAME}" -mountpoint "$MOUNT_POINT" -noverify -quiet

        # Remove existing app from /Applications to prevent permission errors
        if [ -d "/Applications/${APP_BUNDLE_NAME}" ]; then
            echo "Removing existing version from /Applications..."
            rm -rf "/Applications/${APP_BUNDLE_NAME}"
        fi

        # Copy the App
        echo "Copying ${APP_BUNDLE_NAME}..."
        cp -R "${MOUNT_POINT}/${APP_BUNDLE_NAME}" "/Applications/"

        # Unmount (Detach)
        hdiutil detach "$MOUNT_POINT" -quiet
        rmdir "$MOUNT_POINT"

        echo "✅ Installed ${APP_BUNDLE_NAME} to /Applications"
    fi
}

# Main function to parse arguments and call appropriate build function
main() {
    USAGE="Usage: $0 --android|--linux|--linux-remote|--ios|--macos [options]"

    if [ $# -eq 0 ]; then
        echo "$USAGE"
        exit 1
    fi

    MODE="$1"
    shift # Remove the mode from arguments

    case "$MODE" in
        --android)
            build-android "$@"
            ;;
        --linux)
            build-linux "$@"
            ;;
        --linux-remote)
            build-linux-remote "$@"
            ;;
        --ios)
            build-ios "$@"
            ;;
        --macos)
            build-macos "$@"
            ;;
        *)
            echo "Unknown parameter: $MODE"
            echo "$USAGE"
            exit 1
            ;;
    esac
}

# Execute main with all arguments
main "$@"
