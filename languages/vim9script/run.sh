#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"
FILE_NAME_WITHOUT_EXTENSION="${FILE_NAME_WITH_EXTENSION%.*}"

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
    "$IMAGE" \
    vim --version 2>/dev/null | head -n 1

"$ROOT_DIR/utils.sh" "print_separator"

docker run -it --rm \
    -v "$ROOT_DIR":/workspace \
    -w /workspace \
    "$IMAGE" \
    vim -es -c "source /workspace/languages/$LANGUAGE_NAME/$FILE_NAME_WITH_EXTENSION" -c "echom ''" -c "verbose messages" -c "qa!"
