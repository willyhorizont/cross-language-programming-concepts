#!/bin/bash

IMAGE_NAME="cross-language-programming-concepts-r:configured"

if ! docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
    echo "Docker image not found. Running setup.sh..."
    bash ./docker/r/setup.sh
fi

docker run --rm \
    $IMAGE_NAME \
    R --version

echo "---"

docker run --rm \
    -v "$(pwd)":/workspace \
    -w /workspace/languages/r \
    $IMAGE_NAME \
    Rscript "$1"