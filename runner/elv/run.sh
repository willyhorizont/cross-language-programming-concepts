#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LANGUAGE_NAME=$(basename "$SCRIPT_DIR")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

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
