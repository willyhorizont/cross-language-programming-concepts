#!/bin/bash

FILE="$1"

LANGUAGE_NAME="scala"
COMMAND_CHECK_LANGUAGE_VERSION="scala-cli version"
COMMAND_RUN_LANGUAGE_CODE="scala-cli \"$FILE\""
VARIADIC_ARGUMENTS=(
    -v scala-coursier-cache:/root/.cache/coursier
)

bash ./runner/runner.sh \
    "$LANGUAGE_NAME" \
    "$COMMAND_CHECK_LANGUAGE_VERSION" \
    "$COMMAND_RUN_LANGUAGE_CODE" \
    "${VARIADIC_ARGUMENTS[@]}"