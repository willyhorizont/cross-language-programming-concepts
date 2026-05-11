#!/bin/bash

IMAGE_NAME="cross-language-programming-concepts-go:configured"

if ! docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
    echo "Docker image not found. Running setup.sh..."
    bash ./docker/go/setup.sh
fi

docker run --rm \
    $IMAGE_NAME \
    go version

echo "---"

docker run --rm \
    -v "$(pwd)":/workspace \
    -w /workspace/languages/go \
    $IMAGE_NAME \
    go run "$1"