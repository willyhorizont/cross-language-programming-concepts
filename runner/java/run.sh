#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"

LANGUAGE_NAME="java"
COMMAND_CHECK_LANGUAGE_VERSION="java -version && javac -version"
COMMAND_CLEANUP_SETUP_CLASS="
rm -rf runtimes/java/willyhorizont/runtime/*.class
rm -rf runtimes/java/willyhorizont/*.class
rm -rf runtimes/java/*.class
"
COMMAND_RUN_LANGUAGE_CODE="
rm -f ../../runtimes/java/Main.java
rm -f ../../runtimes/java/Main.class

cp $FILE_NAME_WITH_EXTENSION ../../runtimes/java/Main.java
javac -cp ../../runtimes/java -d ../../runtimes/java ../../runtimes/java/Main.java
java -cp ../../runtimes/java Main

rm -f ../../runtimes/java/Main.java
rm -f ../../runtimes/java/Main.class
rm -f ../../runtimes/java/*.class
rm -f ./*.class
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