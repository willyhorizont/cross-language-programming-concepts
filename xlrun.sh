#!/bin/bash

if [ -z "$1" ]; then
    echo "usage: $0 /path/to/target_file"
    exit 1
fi

TARGET_FILE="$(realpath "$1")"
EXT=".${TARGET_FILE##*.}"
JSON_PATH="$(dirname "$(realpath "$0")")/languages.json"

if [ ! -f "$JSON_PATH" ]; then
    echo "Error: languages.json not found at $JSON_PATH"
    exit 1
fi

RUNNER_ID=$(jq -r --arg ext "$EXT" '.[] | select(.file_extension == $ext) | .runner' "$JSON_PATH")

if [ -z "$RUNNER_ID" ] || [ "$RUNNER_ID" == "null" ]; then
    echo "Error: File extension '$EXT' is not supported!"
    exit 1
fi

RUNNER_PATH="$HOME/willyhorizont.github.io/cross-language-programming-concepts/languages/$RUNNER_ID/runner.sh"

if [ -f "$RUNNER_PATH" ]; then
    echo "$RUNNER_PATH $TARGET_FILE"
    bash "$RUNNER_PATH" "$TARGET_FILE"
else
    echo "$RUNNER_PATH not found!"
    exit 1
fi
