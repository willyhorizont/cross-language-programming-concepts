#!/bin/bash

LANGUAGE_NAME="javascript"

IMAGE_NAME="cross-language-programming-concepts-$LANGUAGE_NAME:configured"

docker build \
    -t $IMAGE_NAME \
    -f docker/$LANGUAGE_NAME/Dockerfile \
    .

docker run --rm \
    --entrypoint bash \
    -v "$(pwd)":/workspace \
    -w /workspace \
    $IMAGE_NAME \
    npm install --no-fund --no-audit