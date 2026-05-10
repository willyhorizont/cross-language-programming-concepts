#!/bin/bash

docker run --rm \
    -v "$(pwd)":/workspace \
    -w /workspace/languages/go \
    cross-language-programming-concepts-go:configured \
    go run "$1"