#!/bin/bash

if [ -z "$1" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-extension>"
    exit 0
fi

PATH_TO_FILE_NAME_WITH_EXTENSION="$1"
PATH_TO_FILE_NAME_WITH_EXTENSION_DIR=$(dirname "$PATH_TO_FILE_NAME_WITH_EXTENSION")
FILE_NAME_WITH_EXTENSION=$(basename "$PATH_TO_FILE_NAME_WITH_EXTENSION")
FILE_NAME_WITHOUT_EXTENSION="${FILE_NAME_WITH_EXTENSION%.*}"
FILE_EXTENSION="${FILE_NAME_WITH_EXTENSION##*.}"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LANGUAGE_NAME=$(basename "$SCRIPT_DIR")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

LANGUAGE_ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$LANGUAGE_ENV_FILE" ]; then
    source "$LANGUAGE_ENV_FILE"
fi

"$ROOT_DIR/utils.sh" "setup_language_specific_vscode_extensions" "$LANGUAGE_NAME" 2>/dev/null

IMAGE="thinca/vim:v9.2.0555-basic-ubuntu"

echo "
echo \">docker images\"
$IMAGE
>vim --version 2>/dev/null | head -n 1
"

docker run -it --rm \
    -v "$ROOT_DIR:$ROOT_DIR" \
    -w "$ROOT_DIR" \
    "$IMAGE" \
    vim --version 2>/dev/null | head -n 1

"$ROOT_DIR/utils.sh" "print_separator"

docker run -it --rm \
    -v "$ROOT_DIR:$ROOT_DIR" \
    -w "$ROOT_DIR" \
    "$IMAGE" \
    vim -e -s -c "source $PATH_TO_FILE_NAME_WITH_EXTENSION" -c "echom ''" -c "verbose messages" -c "qa!"
