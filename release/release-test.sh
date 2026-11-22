#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

# Get the directory where this script is located to find the prepare script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

run_session() {
    local PLATFORM="$1"
    local CFG_FILE="$2"
    local FLUTTER_ARGS="$3"
    echo "Starting test on $PLATFORM in directory $(pwd)"
    # Only remove configuration if 'setup' is requested or no args are present (defaulting to all)
    if [[ -z "$FLUTTER_ARGS" ]] || [[ "$FLUTTER_ARGS" == *"setup"* ]]; then
        if [ -f "$CFG_FILE" ]; then
            rm "$CFG_FILE"
            echo "Deleted configuration file: $CFG_FILE"
        fi
    fi
    TEST_FILES=("test_session.dart")
    for TEST_FILE in "${TEST_FILES[@]}"; do
        if flutter test -d "$PLATFORM" "integration_test/$TEST_FILE" "$FLUTTER_ARGS"; then
            echo "✅ $TEST_FILE finished successfully"
        else
            echo "❌ $TEST_FILE failed"
            exit 1
        fi
    done
}

test_mac() {
    local FLUTTER_ARGS="$1"
    CFG_FILE_MACOS="$HOME/Library/Containers/com.mkulesh.onpc/Data/Library/Preferences/com.mkulesh.onpc.plist"
    CFG_FILE_SAVED="./release/config/Library/Containers/com.mkulesh.onpc/Data/Library/Preferences"
    rm -f "$HOME"/Library/Containers/com.mkulesh.onpc/Data/*.log
    run_session "macos" "$CFG_FILE_MACOS" "$FLUTTER_ARGS"
    echo "Moving application logs"
    mv "$HOME"/Library/Containers/com.mkulesh.onpc/Data/release-test.log release
    echo "Copying configuration file"
    mkdir -p "$CFG_FILE_SAVED"
    cp "$CFG_FILE_MACOS" "$CFG_FILE_SAVED"
}

test_linux() {
    local FLUTTER_ARGS="$1"
    CFG_FILE_LINUX="$HOME/.local/share/com.mkulesh.onpc/shared_preferences.json"
    CFG_FILE_SAVED="./release/config/.local/share/com.mkulesh.onpc"
    rm -f release-test.log
    run_session "linux" "$CFG_FILE_LINUX" "$FLUTTER_ARGS"
    echo "Moving application logs"
    mv release-test.log release
    echo "Copying configuration file"
    mkdir -p "$CFG_FILE_SAVED"
    cp "$CFG_FILE_LINUX" "$CFG_FILE_SAVED"
}

test_windows() {
    local FLUTTER_ARGS="$1"
    local APPDATA_DIR="${APPDATA:-$HOME/AppData/Roaming}"
    APPDATA_DIR="${APPDATA_DIR//\\//}"
    CFG_FILE_WINDOWS="${APPDATA_DIR}/Mikhail Kulesh/Music Control/shared_preferences.json"
    CFG_FILE_SAVED="./release/config/Users/family/AppData/Roaming/Mikhail Kulesh/Music Control"
    rm -f release-test.log
    run_session "windows" "$CFG_FILE_WINDOWS" "$FLUTTER_ARGS"
    echo "Moving application logs"
    mv release-test.log release
    echo "Copying configuration file"
    mkdir -p "$CFG_FILE_SAVED"
    cp "$CFG_FILE_WINDOWS" "$CFG_FILE_SAVED"
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
    elif [[ "$(uname)" == "Linux" ]]; then
        test_linux "$TEST_ARGS"
    elif [[ "$(uname)" == MINGW64* ]]; then
        test_windows "$TEST_ARGS"
    else
        echo "Error: Unsupported operating system $(uname)"
        exit 1
    fi
}

main "$@"
