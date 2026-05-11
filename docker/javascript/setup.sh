#!/bin/bash

IMAGE_NAME="cross-language-programming-concepts-javascript:configured"

docker build \
    -t $IMAGE_NAME \
    -f docker/javascript/Dockerfile \
    .

docker run --rm \
    -v "$(pwd)":/workspace \
    -w /workspace \
    $IMAGE_NAME \
    npm install --no-fund --no-audit