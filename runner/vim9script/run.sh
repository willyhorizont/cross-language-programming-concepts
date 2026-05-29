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
IMAGE=${IMAGE:-"thinca/vim:v9.2.0555-basic-ubuntu"}

echo ">$COMMAND_CHECK_LANGUAGE_VERSION"

docker run -it --rm \
    "$IMAGE" \
    vim --version 2>/dev/null | head -n 1

"$ROOT_DIR/utils.sh" "print_separator"

docker run -it --rm \
    -v "$ROOT_DIR":/workspace \
    -w /workspace \
    "$IMAGE" \
    vim -es -c "source /workspace/languages/$LANGUAGE_NAME/$FILE_NAME_WITH_EXTENSION" -c "echom ''" -c "verbose messages" -c "qa!"
