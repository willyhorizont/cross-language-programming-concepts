#!/bin/bash

docker run --rm \
    -v "$(pwd)":/workspace \
    -w /workspace/languages/r \
    cross-language-programming-concepts-r:configured \
    Rscript "$1"