#!/bin/bash
#
# Linux Build Script
# ------------------
# Automates the build process for the Music Control Linux app.
# Uses shared logic to setup the environment, builds the app bundle,
# and wraps it into a distributable .zip file.
#
# Usage:
#   ./build-linux.sh           # Builds the release ZIP
#
# Requirements:
#   - Install Fedora packages:
#     dnf install clang cmake ninja-build gtk3-devel xz-devel
#   - 'flutter' must be in your PATH
#   - Call 'git fetch' in the Flutter directory so that the local Flutter
#     repository gets all the new info from Github

# Exit immediately if any command exits with a non-zero status
set -e

# Get the directory where this script is located to find the prepare script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Call common preparation script
# Args: Version, App Suffix, Platform Type
source "${SCRIPT_DIR}/prepare_build.sh" "3.29.0" "linux-x86_64.zip" "desktop" "$@"

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
mv ${APP_BUNDLE_PATH} "${ONPC_DIR_NAME}"
cp "${ONPC_DIR_NAME}/data/flutter_assets/lib/assets/app_icon.png" "${ONPC_DIR_NAME}/Music-Control.png"

# Archive the new build
cd "${ONPC_RELEASE_DIR}"
zip -qr "${ONPC_APP_NAME}" "$(basename "${ONPC_DIR_NAME}")"

# Check if the archive was actually created
if [ ! -f "${ONPC_APP_NAME}" ]; then
    echo "❌ Error: archive ${ONPC_APP_NAME} was not generated."
    exit 1
fi
echo "✅ Archive generated successfully: ${ONPC_APP_NAME}"
