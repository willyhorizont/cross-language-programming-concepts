#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LANGUAGE_NAME=$(basename "$SCRIPT_DIR")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

DOCKERFILE_PATH="$ROOT_DIR/docker/$LANGUAGE_NAME/Dockerfile"
IMAGE=$(awk 'NR==1 {sub(/^FROM[ ]{1}/,""); print}' "$DOCKERFILE_PATH" 2>/dev/null)
IMAGE=${IMAGE:-"ghcr.io/elves/elvish:v0.21.0"}

COMMAND_CHECK_LANGUAGE_VERSION="/bin/elvish -version"
COMMAND_RUN_LANGUAGE_CODE="
cd /workspace/languages/$LANGUAGE_NAME
elvish $FILE_NAME_WITH_EXTENSION
cd /workspace
"

echo ">$COMMAND_CHECK_LANGUAGE_VERSION"

docker run -it --rm \
    "$IMAGE" \
    elvish -c "$COMMAND_CHECK_LANGUAGE_VERSION"

"$ROOT_DIR/utils.sh" "print_separator"

docker run -it --rm \
    -v "$ROOT_DIR":/workspace \
    -w /workspace \
    "$IMAGE" \
    elvish -c "$COMMAND_RUN_LANGUAGE_CODE"
