#!/bin/bash

LANGUAGE_NAME="javascript"

IMAGE_NAME="cross-language-programming-concepts-$LANGUAGE_NAME:configured"

docker build \
    -t $IMAGE_NAME \
    -f docker/$LANGUAGE_NAME/Dockerfile \
    .

COMMAND_INSTALL_DEPENDENCIES="
rm -rf node_modules package-lock.json
npm install --no-fund --no-audit
"

docker run --rm \
    --entrypoint bash \
    -v "$(pwd)":/workspace \
    -w /workspace \
    $IMAGE_NAME \
    -c "$COMMAND_INSTALL_DEPENDENCIES"