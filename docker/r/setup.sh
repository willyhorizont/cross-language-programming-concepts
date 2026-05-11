#!/bin/bash

LANGUAGE_NAME="r"

IMAGE_NAME="cross-language-programming-concepts-$LANGUAGE_NAME:configured"

docker build \
    -t $IMAGE_NAME \
    -f docker/$LANGUAGE_NAME/Dockerfile \
    .