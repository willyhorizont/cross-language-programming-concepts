#!/bin/bash

LANGUAGE_NAME="java"

IMAGE_NAME="cross-language-programming-concepts-$LANGUAGE_NAME:configured"

docker build \
    -t $IMAGE_NAME \
    -f docker/$LANGUAGE_NAME/Dockerfile \
    .

COMMAND_COMPILE_RUNTIME="
rm -rf runtimes/java/willyhorizont/runtime/*.class
rm -rf runtimes/java/willyhorizont/*.class
rm -rf runtimes/java/*.class
find runtimes/java -name \"*.java\" | xargs javac -d runtimes/java
"

docker run --rm \
    --entrypoint bash \
    -v "$(pwd)":/workspace \
    -w /workspace \
    $IMAGE_NAME \
    -c "$COMMAND_COMPILE_RUNTIME"