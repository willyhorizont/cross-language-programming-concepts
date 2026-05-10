#!/bin/bash

docker build \
    -t cross-language-programming-concepts-javascript:configured \
    -f docker/javascript/Dockerfile \
    .

docker run --rm \
    -v "$(pwd)":/workspace \
    -w /workspace \
    cross-language-programming-concepts-javascript:configured \
    npm install --no-fund --no-audit