#!/bin/bash

IMAGE_NAME="cross-language-programming-concepts-javascript:configured"

if ! docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
    echo "Docker image not found. Running setup.sh..."
    bash ./docker/javascript/setup.sh
fi

docker run --rm \
    $IMAGE_NAME \
    node --version

echo "---"

docker run --rm \
    -v "$(pwd)":/workspace \
    -w /workspace/languages/javascript \
    $IMAGE_NAME \
    node "$1"