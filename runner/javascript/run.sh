#!/bin/bash

docker run --rm \
    -v "$(pwd)":/workspace \
    -w /workspace/languages/javascript \
    cross-language-programming-concepts-javascript:configured \
    node "$1"