#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

# Get the directory where this script is located to find the prepare script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

test_mac() {
    local FLUTTER_ARGS="$1"
    echo "Staring test on macOS in directory $(pwd)"

    rm -f "$HOME"/Library/Containers/com.mkulesh.onpc/Data/*.log

    # Only remove configuration if 'setup' is requested or no args are present (defaulting to all)
    if [[ -z "$FLUTTER_ARGS" ]] || [[ "$FLUTTER_ARGS" == *"setup"* ]]; then
        CFG_FILE_MACOS="$HOME/Library/Containers/com.mkulesh.onpc/Data/Library/Preferences/com.mkulesh.onpc.plist"
        if [ -f "$CFG_FILE_MACOS" ]; then
            rm "$CFG_FILE_MACOS"
            echo "Deleted configuration file: $CFG_FILE_MACOS"
        fi
    fi

    TEST_FILES=("test_session.dart")
    for TEST_FILE in "${TEST_FILES[@]}"; do
        if flutter test -d macos "integration_test/$TEST_FILE" "$FLUTTER_ARGS"; then
            echo "✅ $TEST_FILE finished successfully"
        else
            echo "❌ $TEST_FILE failed"
            exit 1
        fi
    done
    echo "Moving application logs"
    mv "$HOME"/Library/Containers/com.mkulesh.onpc/Data/release-test.log release
}

main() {
    clear
    cd "${SCRIPT_DIR}"
    cd ..

    # Parse arguments to determine test groups
    local SELECTED_GROUPS=""
    for arg in "$@"; do
        case $arg in
            --setup)
                SELECTED_GROUPS="${SELECTED_GROUPS}setup,"
                ;;
            --onkyo)
                SELECTED_GROUPS="${SELECTED_GROUPS}onkyo,"
                ;;
            --denon)
                SELECTED_GROUPS="${SELECTED_GROUPS}denon,"
                ;;
            *)
                echo "Error: Invalid argument '$arg'. Allowed values: --setup, --onkyo, --denon"
                exit 1
                ;;
        esac
    done

    # Remove trailing comma
    SELECTED_GROUPS=${SELECTED_GROUPS%,}

    local TEST_ARGS=""
    if [ -n "$SELECTED_GROUPS" ]; then
        TEST_ARGS="--dart-define=GROUP=$SELECTED_GROUPS"
        echo "Running with groups: $SELECTED_GROUPS"
    fi

    if [[ "$(uname)" == "Darwin" ]]; then
        test_mac "$TEST_ARGS"
    fi
}

main "$@"
