#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../../")

LANGUAGE_ID="zig"

IMAGE_NAME="willyhorizont/zig:0.16.0"

docker build \
    -t "$IMAGE_NAME" \
    -f "$ROOT_DIR/docker/$LANGUAGE_ID/Dockerfile" \
    "$ROOT_DIR"
