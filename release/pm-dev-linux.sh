#!/bin/bash

# Linux Remote Build Script
# -------------------------
# This script automates the process of building the application on a remote Linux machine.
# It connects to the configured remote host via SSH, updates the repository, and triggers
# the build process. Once the build is complete, it downloads the resulting artifact
# back to the local machine.
#
# Prerequisites:
#   - SSH password-less access to the remote host (setup in ~/.ssh/config recommended).
#   - The remote host must have the project repository checked out.
#   - The 'ONPC_HOME' environment variable must be set on the remote host, pointing
#     to the project root.
#
# Usage:
#   ./release/pm-dev-linux.sh
#

# Exit immediately if any command exits with a non-zero status
set -e

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REMOTE_HOST="pm-dev-fedora"
echo "🔍 Resolving remote configuration..."
REMOTE_HOME=$(ssh "$REMOTE_HOST" 'echo $ONPC_HOME')
if [ -z "$REMOTE_HOME" ]; then
    echo "❌ Error: ONPC_HOME environment variable is not set on $REMOTE_HOST or connection failed."
    exit 1
fi

# Execute commands on the remote host
echo "🚀 Connecting to $REMOTE_HOST to start build..."
ssh "$REMOTE_HOST" /bin/bash << 'EOF'
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
    release/build-linux.sh
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
scp -p "$REMOTE_HOST:$REMOTE_FULL_PATH" "$SCRIPT_DIR"

if [ $? -eq 0 ]; then
    echo "✅ Success! Archive copied to current directory."
else
    echo "❌ SCP failed. Please check if the remote archive $REMOTE_FULL_PATH exists on the remote host $REMOTE_HOST"
fi
