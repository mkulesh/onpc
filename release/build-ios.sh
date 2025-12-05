#!/bin/bash
#
# iOS Build Script
# ----------------
# Automates the build process for the Music Control iOS app.
#
# Usage:
#   ./build-ios.sh           # Builds an Ad-Hoc .ipa (Distribution)
#   ./build-ios.sh --deploy  # Builds .ipa and installs to an USB-connected device
#   ./build-ios.sh --store   # Builds an .xcarchive for App Store upload
#
# Requirements:
#   - 'flutter' must be in your PATH
#   - Call 'git fetch' in the Flutter directory so that the local Flutter
#     repository gets all the new info from Github
#   - 'ios-deploy' (via brew) is required for the --deploy flag

# Exit immediately if any command exits with a non-zero status
set -e

# Get the directory where this script is located to find the prepare script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Call common preparation script
# Args: Version, App Suffix, Platform Type
source "${SCRIPT_DIR}/prepare_build.sh" "3.29.0" "ios.ipa" "mobile" "$@"

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
