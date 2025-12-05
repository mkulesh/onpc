#!/bin/bash
#
# macOS Build Script
# ------------------
# Automates the build process for the Music Control macOS app.
# Uses shared logic to setup the environment, builds the .app bundle,
# and wraps it into a distributable .dmg file.
#
# Usage:
#   ./build-macos.sh           # Builds the release DMG
#   ./build-macos.sh --deploy  # Builds and installs to Applications
#
# Requirements:
#   - 'flutter' must be in your PATH
#   - Call 'git fetch' in the Flutter directory so that the local Flutter
#     repository gets all the new info from Github
#   - 'create-dmg' (via brew) is required to generate the installer image.
#     If "Not authorized to send Apple events to Finder" appears:
#     tccutil reset AppleEvents com.google.android.studio

# Exit immediately if any command exits with a non-zero status
set -e

# Get the directory where this script is located to find the prepare script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Call common preparation script
# Args: Version, App Suffix, Platform Type
source "${SCRIPT_DIR}/prepare_build.sh" "3.29.0" "macos.dmg" "desktop" "$@"

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