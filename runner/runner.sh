#!/bin/bash

LANGUAGE_NAME="$1"
COMMAND_CHECK_LANGUAGE_VERSION="$2"
COMMAND_RUN_LANGUAGE_CODE="$3"

IMAGE_NAME="cross-language-programming-concepts-$LANGUAGE_NAME:configured"

if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo "Docker image not found. Running setup.sh..."
    bash "./docker/$LANGUAGE_NAME/setup.sh"
fi

docker run --rm \
    "$IMAGE_NAME" \
    bash -c "$COMMAND_CHECK_LANGUAGE_VERSION"

echo "---"

docker run --rm \
    -v "$(pwd)":/workspace \
    -w "/workspace/languages/$LANGUAGE_NAME" \
    "$IMAGE_NAME" \
    bash -c "$COMMAND_RUN_LANGUAGE_CODE"