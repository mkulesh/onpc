#!/bin/bash
#
# prepare_build.sh
# ----------------
# Shared logic for preparing the Flutter build environment.
#
# Usage:
#   source ./prepare_build.sh <FLUTTER_VERSION> <APP_SUFFIX> <PLATFORM_TYPE>

# Check arguments
if [ "$#" -lt 3 ]; then
    echo "Error: prepare_build.sh requires at least 3 arguments: <FLUTTER_VERSION> <APP_SUFFIX> <PLATFORM_TYPE>"
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
export DEPLOY_TO_DEVICE

# 1. Setup Project Paths
ONPC_RELEASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export ONPC_RELEASE_DIR

# Navigate to release dir to ensure relative paths work
cd "${ONPC_RELEASE_DIR}" || exit 1
ONPC_PROJECT_ROOT="$(cd .. && pwd)"
export ONPC_PROJECT_ROOT

# 2. Setup Flutter Environment
FLUTTER_BIN=$(which flutter)
if [ -z "$FLUTTER_BIN" ]; then
    echo "Error: 'flutter' command not found in PATH."
    exit 1
fi
ONPC_FLUTTER_PATH="$(dirname "$(dirname "$FLUTTER_BIN")")"
export ONPC_FLUTTER_PATH

echo "Setting up Flutter ${TARGET_FLUTTER_VER}..."
cd "${ONPC_FLUTTER_PATH}" || exit
git checkout -f "${TARGET_FLUTTER_VER}"
export FLUTTER_GIT_URL="https://github.com/flutter/flutter.git"

# 3. Setup the APP name with version
cd "${ONPC_RELEASE_DIR}" || exit
if [ ! -f "VERSION.txt" ]; then
    echo "Error: VERSION.txt not found in ${ONPC_RELEASE_DIR}"
    exit 1
fi
ONPC_APP_VER=$(cat VERSION.txt)
export ONPC_APP_VER
ONPC_APP_NAME="MusicControl-v${ONPC_APP_VER}-${TARGET_SUFFIX}"
export ONPC_APP_NAME

# Remove previous build artifact
rm -f "${ONPC_APP_NAME}"

# 4. Setup Project Files (Symlinks)
echo "Preparing project files for ${TARGET_PLATFORM}..."
cd "${ONPC_PROJECT_ROOT}" || exit

# Update pubspec.yaml
rm -f "pubspec.yaml"
ln -s "pubspec.yaml_${TARGET_PLATFORM}" "pubspec.yaml"

# Update CompatUtils.dart
rm -f "lib/utils/CompatUtils.dart"
ln -s "CompatUtils.dart.${TARGET_PLATFORM}" "lib/utils/CompatUtils.dart"

# 5. Info & Clean
echo "------------------------------------------------"
echo "Starting build for: ${ONPC_APP_NAME}"
echo "Flutter SDK: ${ONPC_FLUTTER_PATH}"
echo "Project root: ${ONPC_PROJECT_ROOT}"
echo "Release dir: ${ONPC_RELEASE_DIR}"
echo "Target platform: ${TARGET_PLATFORM}"
echo "------------------------------------------------"

echo "Cleaning project..."
flutter clean && flutter doctor

echo "Resolving dependencies..."
set -o pipefail
flutter pub get | grep -vE "^\+ |^\- |available\)"
