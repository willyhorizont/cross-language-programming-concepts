#!/bin/bash

docker build \
    -t cross-language-programming-concepts-javascript:configured \
    -f docker/javascript/Dockerfile \
    .