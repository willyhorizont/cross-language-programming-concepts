#!/bin/bash

docker build \
    -t cross-language-programming-concepts-go:configured \
    -f docker/go/Dockerfile \
    .