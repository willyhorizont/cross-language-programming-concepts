#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"
FILE_NAME_WITHOUT_EXTENSION="${FILE_NAME_WITH_EXTENSION%.*}"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LANGUAGE_NAME=$(basename "$SCRIPT_DIR")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

LANGUAGE_ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$LANGUAGE_ENV_FILE" ]; then
    source "$LANGUAGE_ENV_FILE"
fi

"$ROOT_DIR/utils.sh" "setup_language_specific_vscode_extensions" "$LANGUAGE_NAME" 2>/dev/null

IMAGE="ghcr.io/elves/elvish:v0.21.0"

COMMAND_CHECK_LANGUAGE_VERSION="
echo \">docker images\"
echo \"$IMAGE\"
echo \">elvish -version\"
/bin/elvish -version
"

COMMAND_RUN_LANGUAGE_CODE="
cd /workspace/languages/$LANGUAGE_NAME
elvish $FILE_NAME_WITH_EXTENSION
cd /workspace
"

docker run -it --rm \
    -v "$ROOT_DIR":/workspace \
    -w /workspace \
    "$IMAGE" \
    elvish -c "$COMMAND_CHECK_LANGUAGE_VERSION"

"$ROOT_DIR/utils.sh" "print_separator"

docker run -it --rm \
    -v "$ROOT_DIR":/workspace \
    -w /workspace \
    "$IMAGE" \
    elvish -c "$COMMAND_RUN_LANGUAGE_CODE"
