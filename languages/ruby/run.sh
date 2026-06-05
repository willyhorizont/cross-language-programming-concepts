#!/bin/bash

if [ -z "$1" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-extension>"
    exit 1
fi

PATH_TO_FILE_NAME_WITH_EXTENSION="$1"
PATH_TO_FILE_NAME_WITH_EXTENSION_DIR="$(dirname "$PATH_TO_FILE_NAME_WITH_EXTENSION")"
FILE_NAME_WITH_EXTENSION="$(basename "$PATH_TO_FILE_NAME_WITH_EXTENSION")"
FILE_NAME_WITHOUT_EXTENSION="${FILE_NAME_WITH_EXTENSION%.*}"
FILE_EXTENSION="${FILE_NAME_WITH_EXTENSION##*.}"

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
LANGUAGE_NAME="$(basename "$SCRIPT_DIR")"
ROOT_DIR="$(realpath "$SCRIPT_DIR/../..")"

LANGUAGE_ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$LANGUAGE_ENV_FILE" ]; then
    source "$LANGUAGE_ENV_FILE"
fi

"$ROOT_DIR/utils.sh" "setup_language_specific_vscode_extensions" "$LANGUAGE_NAME" 2>/dev/null

IMAGE=$("$ROOT_DIR/utils.sh" "get_docker_image" "$LANGUAGE_NAME" 2>/dev/null)

SEPARATOR=$("$ROOT_DIR/utils.sh" "print_separator")

COMMAND_PRINT_VERSION="
echo \">docker images\"
echo \"$IMAGE\"
echo \">ruby -v\"
ruby -v
echo \">ruby --version\"
ruby --version
"

COMMAND_RUN_LANGUAGE_CODE="
ruby \"$FILE_NAME_WITH_EXTENSION\"
"

docker run -i --rm \
    --entrypoint bash \
    -v "$ROOT_DIR:$ROOT_DIR" \
    "$IMAGE" \
    -c "
        $COMMAND_PRINT_VERSION

        echo \"$SEPARATOR\"

        cd \"$PATH_TO_FILE_NAME_WITH_EXTENSION_DIR\"

        $COMMAND_RUN_LANGUAGE_CODE

        cd \"$ROOT_DIR\"
    "
