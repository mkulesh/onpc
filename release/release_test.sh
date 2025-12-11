#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

# Get the directory where this script is located to find the prepare script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

test_mac() {
    echo "Staring test on macOS in directory $(pwd)"

    rm -f "$HOME"/Library/Containers/com.mkulesh.onpc/Data/*.log
    
    CFG_FILE_MACOS="$HOME/Library/Containers/com.mkulesh.onpc/Data/Library/Preferences/com.mkulesh.onpc.plist"
    if [ -f "$CFG_FILE_MACOS" ]; then
        rm "$CFG_FILE_MACOS"
        echo "Deleted configuration file: $CFG_FILE_MACOS"
    fi

    TEST_FILES=("app_setup.dart" "onkyo_player_test.dart" "denon_avr_test.dart")
    for TEST_FILE in "${TEST_FILES[@]}"; do
        if flutter test -d macos "integration_test/$TEST_FILE"; then
            echo "✅ $TEST_FILE finished successfully"
        else
            echo "❌ $TEST_FILE failed"
            exit 1
        fi
    done
    echo "Application logs:"
    ls -l "$HOME"/Library/Containers/com.mkulesh.onpc/Data/*.log
}

main() {
    cd "${SCRIPT_DIR}"
    cd ..

    if [[ "$(uname)" == "Darwin" ]]; then
        test_mac
    fi
}

main
