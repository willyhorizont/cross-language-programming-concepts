#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"

LANGUAGE_NAME="scala"
COMMAND_CHECK_LANGUAGE_VERSION="scala-cli version"
COMMAND_RUN_LANGUAGE_CODE="scala-cli \"$FILE_NAME_WITH_EXTENSION\""

bash ./runner/runner.sh \
    "$LANGUAGE_NAME" \
    "$COMMAND_CHECK_LANGUAGE_VERSION" \
    "NULL"

IMAGE_NAME="cross-language-programming-concepts-$LANGUAGE_NAME:configured"

docker run --rm \
    --entrypoint bash \
    -v scala-coursier-cache:/root/.cache/coursier \
    -v "$(pwd)":/workspace \
    -w "/workspace/languages/$LANGUAGE_NAME" \
    "$IMAGE_NAME" \
    -c "$COMMAND_RUN_LANGUAGE_CODE"