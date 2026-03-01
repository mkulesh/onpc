#!/bin/bash
#
# Unified Build Script
# --------------------
# Automates the build process for the Music Control app across all platforms.
#
# Usage:
#   ./build-app.sh mode [flags]
#
# Modes:
#   --android           Build for Android locally.
#   --ios               Build for iOS locally.
#   --linux             Build for Linux locally.
#   --linux-remote      Build for Linux on a remote host.
#   --macos             Build for macOS locally.
#   --windows           Build for Windows locally.
#   --windows-remote    Build for Windows on a remote host.
#   --all               Build for all platforms.
#
# Flags:
#   --install           Install the application to the connected device or local machine.
#                       Supported modes: --android, --ios, --macos, --windows.
#   --store             Build for store distribution.
#                       Supported modes: --ios, --windows.
#
# Requirements:
#   - 'flutter' must be in PATH variable
#   - Call 'git fetch' in the Flutter directory so that the local Flutter
#     repository gets all the new info from Github
#   - Platform specific requirements:
#     -- Android: 'adb' (Android Debug Bridge) is required for the --install flag
#     -- iOS: 'ios-deploy' (via brew) is required for the --install flag:
#        brew install ios-deploy
#     -- Linux: Install additional packages:
#        dnf install clang cmake ninja-build gtk3-devel xz-devel
#     -- macOS: 'create-dmg' (via brew) is required to generate the installer image:
#        brew install create-dmg
#        If "Not authorized to send Apple events to Finder" appears:
#        tccutil reset AppleEvents com.google.android.studio
#     -- Windows: Visual Studio 2019 or later with "Desktop development with C++" workload.
#        "git config --global http.sslBackend schannel" - use Windows certificate chain
#   - Requirement for the remote build:
#     -- SSH password-less access to the Linux host
#        cd ~/.ssh
#        ssh-keygen (linux host) or
#        ssh-copy-id -i ./id_rsa.pub user@host
#        scp ./id_ecdsa.pub family@pm-dev-windows:C:/ProgramData/ssh/administrators_authorized_keys
#     -- SSH password-less access to the Windows host
#        cd ~/.ssh
#        ssh-keygen -t ecdsa
#        scp ./id_ecdsa.pub user@host:C:/ProgramData/ssh/administrators_authorized_keys
#     -- The remote host must have the project repository checked out.
#     -- The 'ONPC_HOME' environment variable must be set on the remote host, pointing
#        to the project root.

# Exit immediately if any command exits with a non-zero status
set -e

# Get the directory where this script is located
ONPC_RELEASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Common parameters
USAGE="Usage: $0 <mode> [flags]\nTry '$0 --help' for more information."
REMOTE_HOST_LINUX="pm-dev-fedora"
REMOTE_HOST_WINDOWS="pm-dev-windows"

# Shared logic for preparing the application name.
# Usage:
#   prepare-app-name <APP_SUFFIX>
prepare-app-name() {
    VERSION_FILE="$ONPC_RELEASE_DIR/VERSION.txt"
    if [ ! -f "$VERSION_FILE" ]; then
        echo "❌ Error: VERSION.txt not found in $ONPC_RELEASE_DIR"
        exit 1
    fi
    ONPC_APP_VER=$(cat "$VERSION_FILE")
    ONPC_APP_NAME="MusicControl-v$ONPC_APP_VER-$1"
}

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
    INSTALL_TO_DEVICE=false
    BUILD_FOR_STORE=false
    shift 3
    for arg in "$@"
    do
        if [ "$arg" == "--install" ]; then
            INSTALL_TO_DEVICE=true
        fi
        if [ "$arg" == "--store" ]; then
            BUILD_FOR_STORE=true
        fi
    done

    # Navigate to release dir to ensure relative paths work
    cd "$ONPC_RELEASE_DIR" || exit 1
    ONPC_PROJECT_ROOT="$(cd .. && pwd)"

    # Setup Flutter Environment
    FLUTTER_BIN=$(which flutter)
    if [ -z "$FLUTTER_BIN" ]; then
        echo "Error: 'flutter' command not found in PATH."
        exit 1
    fi
    ONPC_FLUTTER_PATH="$(dirname "$(dirname "$FLUTTER_BIN")")"

    echo "Setting up Flutter $TARGET_FLUTTER_VER..."
    cd "$ONPC_FLUTTER_PATH" || exit
    git checkout -f "$TARGET_FLUTTER_VER"
    export FLUTTER_GIT_URL="https://github.com/flutter/flutter.git"

    # Setup the APP name with version
    prepare-app-name "$TARGET_SUFFIX"

    # Remove previous build artifact
    cd "$ONPC_RELEASE_DIR" || exit
    rm -f "$ONPC_APP_NAME"

    # Setup Project Files (Symlinks)
    echo "Preparing project files for $TARGET_PLATFORM..."
    cd "$ONPC_PROJECT_ROOT" || exit
    flutter clean

    # Update pubspec.yaml
    rm -f "pubspec.yaml"
    ln -s "pubspec.yaml_$TARGET_PLATFORM" "pubspec.yaml"

    # Update CompatUtils.dart
    rm -f "lib/utils/CompatUtils.dart"
    ln -s "CompatUtils.dart.$TARGET_PLATFORM" "lib/utils/CompatUtils.dart"

    # Info & Clean
    echo "------------------------------------------------"
    echo "Starting build for: $ONPC_APP_NAME"
    echo "Flutter SDK: $ONPC_FLUTTER_PATH"
    echo "Project root: $ONPC_PROJECT_ROOT"
    echo "Release dir: $ONPC_RELEASE_DIR"
    echo "Target platform: $TARGET_PLATFORM"
    echo "Build for store: $BUILD_FOR_STORE"
    echo "Install to device: $INSTALL_TO_DEVICE"
    echo "------------------------------------------------"

    flutter config --no-enable-web &> /dev/null
    flutter doctor

    set -o pipefail
    flutter pub get | grep -vE "^\+ |^- |available\)"
}

# Shared logic for moving generated application bundle.
# Usage:
#   move-bundle <APP_BUNDLE_NAME>
move-bundle() {
    APP_BUNDLE_NAME="$1"
    if [ -f "$APP_BUNDLE_NAME" ]; then
        mv "$APP_BUNDLE_NAME" "$ONPC_RELEASE_DIR/$ONPC_APP_NAME"
        echo "✅ Success! application bundle available at: $ONPC_RELEASE_DIR/$ONPC_APP_NAME"
    else
        echo "❌ Error: application bundle was not generated."
        exit 1
    fi
}

# Shared logic for copying generated application bundle from remote host.
# Usage:
#   move-remote-bundle <REMOTE_HOST> <REMOTE_FULL_PATH>
move-remote-bundle() {
    REMOTE_HOST="$1"
    REMOTE_FULL_PATH="$2"
    echo "📦 Copying remote archive $REMOTE_FULL_PATH..."
    scp -p "$REMOTE_HOST:$REMOTE_FULL_PATH" "$ONPC_RELEASE_DIR"
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        echo "✅ Success! Archive copied to current directory."
    else
        echo "❌ SCP failed. Please check if the remote archive $REMOTE_FULL_PATH exists on the remote host $REMOTE_HOST"
    fi
}

# Android Build Method
build-android() {
    echo "Building Android application..."
    prepare-build "3.29.0" "android.apk" "mobile" "$@"
    flutter build apk --release

    move-bundle "$(find build/app/outputs/flutter-apk -maxdepth 1 -name "app-release.apk" | head -n 1)"

    # Install if requested
    if [ "$INSTALL_TO_DEVICE" = true ]; then
        echo "Installing to connected Android device..."
        if ! command -v adb &> /dev/null; then
            echo "❌ Error: 'adb' command not found. Cannot deploy."
            exit 1
        fi
        adb install -r "$ONPC_RELEASE_DIR/$ONPC_APP_NAME"
        echo "Starting application..."
        adb shell am start -n "com.mkulesh.onpc.plus/com.mkulesh.onpc.plus.MainActivity"
    fi
}

# iOS Build Method
build-ios() {
    echo "Building iOS application..."
    prepare-build "3.29.0" "ios.ipa" "mobile" "$@"
    if [ "$BUILD_FOR_STORE" = true ]; then
        echo "Building for Store (creating .app/.xcarchive)..."
        flutter build ios --release
    else
        echo "Building for Distribution/Ad-Hoc..."
        flutter build ipa --release --export-options-plist="$ONPC_RELEASE_DIR/build-ios-options.plist"
        move-bundle "$(find build/ios/ipa -maxdepth 1 -name "*.ipa" | head -n 1)"
    fi

    # Install if requested
    if [ "$INSTALL_TO_DEVICE" = true ]; then
        echo "Installing to connected iOS device..."
        if ! command -v ios-deploy &> /dev/null; then
            echo "❌ Error: 'ios-deploy' not found. Please run: brew install ios-deploy"
            exit 1
        fi
        ios-deploy --bundle "$ONPC_RELEASE_DIR/$ONPC_APP_NAME" --no-wifi > /dev/null
    fi
}

# Linux Build Method
build-linux() {
    echo "Building Linux application..."
    prepare-build "3.29.0" "linux-x86_64.zip" "desktop" "$@"

    # Remove the old build
    ONPC_DIR_NAME="$ONPC_RELEASE_DIR/${ONPC_APP_NAME%.*}"
    rm -rf "$ONPC_DIR_NAME"

    # Build app
    flutter build linux --release

    # Check the generated application bundle
    APP_BUNDLE_PATH="build/linux/x64/release/bundle"
    APP_BUNDLE_NAME="$APP_BUNDLE_PATH/Music-Control"
    if [ ! -d "$APP_BUNDLE_PATH" ]; then
        echo "❌ Error: application bundle was not generated in $APP_BUNDLE_PATH"
        exit 1
    fi
    echo "✅ Found application bundle: $APP_BUNDLE_NAME"

    # Move the application bundle
    mv "$APP_BUNDLE_PATH" "$ONPC_DIR_NAME"
    ICON_SRC="$ONPC_DIR_NAME/data/flutter_assets/lib/assets/app_icon.png"
    if [ -f "$ICON_SRC" ]; then
        cp "$ICON_SRC" "$ONPC_DIR_NAME/Music-Control.png"
    else
        echo "⚠️ Warning: App Icon not found at $ICON_SRC"
    fi

    # Archive the new build
    cd "$ONPC_RELEASE_DIR"
    zip -qr "$ONPC_APP_NAME" "$(basename "$ONPC_DIR_NAME")"

    # Check if the archive was actually created
    if [ ! -f "$ONPC_APP_NAME" ]; then
        echo "❌ Error: archive $ONPC_APP_NAME was not generated."
        exit 1
    fi
    echo "✅ Archive generated successfully: $ONPC_APP_NAME"
}

# Linux Build Method on a remote host
build-linux-remote() {
    echo "🔍 Resolving remote configuration..."
    REMOTE_HOME=$(ssh "$REMOTE_HOST_LINUX" 'echo $ONPC_HOME')
    if [ -z "$REMOTE_HOME" ]; then
        echo "❌ Error: ONPC_HOME environment variable is not set on $REMOTE_HOST_LINUX or connection failed."
        exit 1
    fi

    # Execute commands on the remote host
    echo "🚀 Connecting to $REMOTE_HOST_LINUX to start build..."
    ssh "$REMOTE_HOST_LINUX" /bin/bash << 'EOF'
        # Stop on error
        set -e

        # Check if ONPC_HOME is set
        if [ -z "$ONPC_HOME" ]; then
            echo "❌ Error: ONPC_HOME environment variable is not set on remote host."
            exit 1
        fi

        echo "📂 Navigating to project root: $ONPC_HOME"
        cd "$ONPC_HOME" || { echo "❌ Directory not found"; exit 1; }

        echo "🔄 Updating source..."
        ./clean.sh
        git checkout .
        git pull

        echo "🔨 Building..."
        release/build-app.sh --linux
EOF

    # Check if the SSH command succeeded
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        echo "✅ Remote build finished successfully in $REMOTE_HOME"
    else
        echo "❌ Remote build failed."
        exit 1
    fi

    prepare-app-name "linux-x86_64.zip"
    move-remote-bundle $REMOTE_HOST_LINUX "$REMOTE_HOME/release/$ONPC_APP_NAME"
}

# macOS Build Method
build-macos() {
    echo "Building macOS application..."
    prepare-build "3.29.0" "macos.dmg" "desktop" "$@"
    flutter build macos --release

    # Locate the generated .app bundle dynamically
    APP_BUNDLE_PATH=$(find build/macos/Build/Products/Release -maxdepth 1 -name "*.app" | head -n 1)
    if [ -z "$APP_BUNDLE_PATH" ]; then
        echo "❌ Error: .app bundle was not generated in build/macos/Build/Products/Release/"
        exit 1
    fi
    APP_BUNDLE_NAME=$(basename "$APP_BUNDLE_PATH")
    echo "✅ Found application bundle: $APP_BUNDLE_NAME"

    # Create DMG image
    rm -f "$ONPC_RELEASE_DIR/$ONPC_APP_NAME"
    echo "Creating DMG image..."
    if ! command -v create-dmg &> /dev/null; then
        echo "❌ Error: 'create-dmg' not found. Please run: brew install create-dmg"
        exit 1
    fi
    create-dmg \
      --volname "MusicControl-v$ONPC_APP_VER" \
      --window-pos 200 120 \
      --window-size 800 400 \
      --icon-size 100 \
      --icon "$APP_BUNDLE_NAME" 200 190 \
      --hide-extension "$APP_BUNDLE_NAME" \
      --app-drop-link 600 185 \
      --hdiutil-quiet \
      "$ONPC_RELEASE_DIR/$ONPC_APP_NAME" \
      "$APP_BUNDLE_PATH"

    echo "✅ Success! DMG available at: $ONPC_RELEASE_DIR/$ONPC_APP_NAME"

    # Install if requested
    if [ "$INSTALL_TO_DEVICE" = true ]; then
        echo "Installing to local machine..."

        # Mount the DMG
        # -noverify: Skip verification for speed
        # -mountpoint: Mount to a specific temporary path
        MOUNT_POINT="/tmp/MusicControl_Install"
        mkdir -p "$MOUNT_POINT"

        hdiutil attach "$ONPC_RELEASE_DIR/$ONPC_APP_NAME" -mountpoint "$MOUNT_POINT" -noverify -quiet

        # Remove existing app from /Applications to prevent permission errors
        if [ -d "/Applications/$APP_BUNDLE_NAME" ]; then
            echo "Removing existing version from /Applications..."
            rm -rf "/Applications/$APP_BUNDLE_NAME"
        fi

        # Copy the App
        echo "Copying $APP_BUNDLE_NAME..."
        cp -R "$MOUNT_POINT/$APP_BUNDLE_NAME" "/Applications/"

        # Unmount (Detach)
        hdiutil detach "$MOUNT_POINT" -quiet
        rmdir "$MOUNT_POINT"

        echo "✅ $ONPC_APP_NAME installed successfully."
    fi
}

# Windows Build Method
build-windows() {
    echo "Building Windows application..."
    prepare-build "3.29.0" "windows-x86_64.msix" "desktop" "$@"
    flutter build windows --release

    # Create MSIX
    if [ "$BUILD_FOR_STORE" = true ]; then
        echo "Generating MSIX for Store (non signed)..."
        flutter pub run msix:create --store
    else
        echo "Generating MSIX for ad-hoc distribution (signed)..."
        flutter pub run msix:create
    fi
    echo ""

    move-bundle "build/windows/x64/runner/Release/onpc.msix"

    # Install if requested
    if [ "$INSTALL_TO_DEVICE" = true ]; then
        echo "Installing to local machine..."
        
        # Convert path to Windows format if cygpath is available
        MSIX_PATH="$ONPC_RELEASE_DIR/$ONPC_APP_NAME"
        if command -v cygpath &> /dev/null; then
            MSIX_PATH=$(cygpath -w "$MSIX_PATH")
        fi
        
        # Avoid "The provided package is already installed" error
        PACKAGE_NAME="25529MikhailKulesh.EnhancedMusicController"
        echo "Checking for existing installation of $PACKAGE_NAME..."
        powershell.exe -command "if (Get-AppxPackage -Name '$PACKAGE_NAME') { Write-Host 'Removing existing package...'; Get-AppxPackage -Name '$PACKAGE_NAME' | Remove-AppxPackage }"

        echo "Installing $MSIX_PATH..."
        powershell.exe -command "Add-AppxPackage -Path '$MSIX_PATH' -ForceUpdateFromAnyVersion"
        # shellcheck disable=SC2181
        if [ $? -eq 0 ]; then
             echo "✅ $ONPC_APP_NAME installed successfully."
        else
             echo "❌ Error: Failed to install application."
             exit 1
        fi
    fi
}

# Windows Build Method on a remote host
build-windows-remote() {
    echo "🔍 Resolving remote configuration..."
    REMOTE_HOME=$(ssh "$REMOTE_HOST_WINDOWS" "powershell.exe -Command \"Write-Output \$env:ONPC_HOME\"")
    REMOTE_HOME=$(echo "$REMOTE_HOME" | tr -d '\r')
    if [ -z "$REMOTE_HOME" ]; then
        echo "❌ Error: ONPC_HOME environment variable is not set on $REMOTE_HOST_WINDOWS or connection failed."
        exit 1
    fi

    # Execute commands on the remote host
    echo "🚀 Connecting to $REMOTE_HOST_WINDOWS to start build..."
    ssh "$REMOTE_HOST_WINDOWS" "C:/PROGRA~1/Git/bin/bash.exe --login" << 'EOF'
        # Stop on error
        set -e

        # Check if ONPC_HOME is set
        if [ -z "$ONPC_HOME" ]; then
            echo "❌ Error: ONPC_HOME environment variable is not set on remote host."
            exit 1
        fi

        echo "📂 Navigating to project root: $ONPC_HOME"
        cd "$ONPC_HOME" || { echo "❌ Directory not found"; exit 1; }

        echo "🔄 Updating source..."
        ./clean.sh
        git checkout .
        git pull

        echo "🔨 Building..."
        release/build-app.sh --windows
EOF

    # Check if the SSH command succeeded
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        echo "✅ Remote build finished successfully in $REMOTE_HOME"
    else
        echo "❌ Remote build failed."
        exit 1
    fi

    prepare-app-name "windows-x86_64.msix"
    
    # We need to correctly format the path for SCP.
    REMOTE_HOME_FWD=$(echo "$REMOTE_HOME" | sed 's/\\/\//g')
    if [[ "$REMOTE_HOME_FWD" =~ ^/[a-zA-Z]/ ]]; then
       # shellcheck disable=SC2001
       REMOTE_HOME_FWD=$(echo "$REMOTE_HOME_FWD" | sed 's|^/\([a-zA-Z]\)/|\1:/|')
    fi

    move-remote-bundle $REMOTE_HOST_WINDOWS "$REMOTE_HOME_FWD/release/$ONPC_APP_NAME"
}

# Main function to parse arguments and call appropriate build function
main() {
    if [ $# -eq 0 ]; then
        echo -e "$USAGE"
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
        --windows)
            build-windows "$@"
            ;;
        --windows-remote)
            build-windows-remote "$@"
            ;;
        --all)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                 build-android "$@"
                 build-ios "$@"
                 build-macos "$@"
                 build-linux-remote "$@"
                 build-windows-remote "$@"
            else
                 echo "⚠️ Warning: --all is not applicable on this OS. Only macOS supports building all targets."
            fi
            ;;
        --help)
            # Print the header comments (skip shebang and blank lines in header)
            sed -n '2,/^$/p' "$0" | sed 's/^# //;s/^#//'
            exit 0
            ;;
        *)
            echo "Unknown parameter: $MODE"
            echo -e "$USAGE"
            exit 1
            ;;
    esac
}

# Execute main with all arguments
main "$@"
