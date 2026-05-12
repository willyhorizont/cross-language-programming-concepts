#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"

LANGUAGE_NAME="java"
COMMAND_CHECK_LANGUAGE_VERSION="java -version && javac -version"
COMMAND_RUN_LANGUAGE_CODE="
rm -f \"../../runner/java/Main.java\" && \
cp \"$FILE_NAME_WITH_EXTENSION\" \"../../runner/java/Main.java\" && \
javac \"../../runner/java/Main.java\" && \
java -cp \"../../runner/java\" Main && \
rm -f "../../runner/java/*.class" && \
rm -f "./*.class" && \
rm -f "../../runner/java/Main.java"
"

bash ./runner/runner.sh \
    "$LANGUAGE_NAME" \
    "$COMMAND_CHECK_LANGUAGE_VERSION" \
    "NULL"

IMAGE_NAME="cross-language-programming-concepts-$LANGUAGE_NAME:configured"

docker run --rm \
    --entrypoint bash \
    -v "$(pwd)":/workspace \
    -w "/workspace/languages/$LANGUAGE_NAME" \
    "$IMAGE_NAME" \
    -c "$COMMAND_RUN_LANGUAGE_CODE"