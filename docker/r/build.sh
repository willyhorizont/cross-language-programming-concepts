#!/bin/bash

docker build \
    -t cross-language-programming-concepts-r:configured \
    -f docker/r/Dockerfile \
    .