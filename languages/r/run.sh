#!/bin/bash

if [ -z "$1" -o -z "$2" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-ext> <language>"
    exit 0
fi

PATH_TO_FILE_NAME_WITH_EXTENSION="$1"
LANGUAGE_NAME="$2"
FILE_NAME_WITH_EXTENSION=$(basename "$PATH_TO_FILE_NAME_WITH_EXTENSION")
FILE_NAME_WITHOUT_EXTENSION="${FILE_NAME_WITH_EXTENSION%.*}"
FILE_EXTENSION="${FILE_NAME_WITH_EXTENSION##*.}"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

PATH_TO_TEMP_FILE_WITH_EXTENSION="$ROOT_DIR/languages/$LANGUAGE_NAME/temp.$FILE_EXTENSION"
cp -f "$PATH_TO_FILE_NAME_WITH_EXTENSION" "$PATH_TO_TEMP_FILE_WITH_EXTENSION"

LANGUAGE_ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$LANGUAGE_ENV_FILE" ]; then
    source "$LANGUAGE_ENV_FILE"
fi

"$ROOT_DIR/utils.sh" "setup_language_specific_vscode_extensions" "$LANGUAGE_NAME" 2>/dev/null

IMAGE="r-base:4.6.0"

COMMAND_CHECK_LANGUAGE_VERSION="
echo \">docker images\"
echo \"$IMAGE\"
echo \">R --version\"
R --version
"

COMMAND_RUN_LANGUAGE_CODE="
cd /workspace/languages/$LANGUAGE_NAME

Rscript temp.$FILE_EXTENSION
rm -rf temp.$FILE_EXTENSION
"

docker run -it --rm \
    --entrypoint bash \
    -v "$ROOT_DIR":/workspace \
    -w /workspace \
    "$IMAGE" \
    -c "
        $COMMAND_CHECK_LANGUAGE_VERSION

        \"/workspace/utils.sh\" \"print_separator\"

        $COMMAND_RUN_LANGUAGE_CODE
    "
