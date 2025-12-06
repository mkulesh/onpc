#!/bin/bash
#
# Android Build Script
# --------------------
# Automates the build process for the Music Control Android app.
# Uses shared logic (prepare_build.sh) to setup the environment/symlinks,
# builds the release APK, and handles optional deployment.
#
# Usage:
#   ./build-android.sh           # Builds the release APK
#   ./build-android.sh --deploy  # Builds and installs to a connected Android device
#
# Requirements:
#   - 'flutter' must be in your PATH
#   - Call 'git fetch' in the Flutter directory so that the local Flutter
#     repository gets all the new info from Github
#   - 'adb' (Android Debug Bridge) is required for the --deploy flag

# Exit immediately if any command exits with a non-zero status
set -e

# Get the directory where this script is located to find the prepare script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Call common preparation script
# Args: Version, App Suffix, Platform Type
source "${SCRIPT_DIR}/prepare_build.sh" "3.29.0" "android.apk" "mobile" "$@"

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
