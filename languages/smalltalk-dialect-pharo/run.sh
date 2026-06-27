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
LANGUAGE_ID="$(basename "$SCRIPT_DIR")"
ROOT_DIR="$(realpath "$SCRIPT_DIR/../..")"

LANGUAGE_ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_ID"

if [ -f "$LANGUAGE_ENV_FILE" ]; then
    source "$LANGUAGE_ENV_FILE"
fi

"$ROOT_DIR/utils.sh" "setup_language_specific_vscode_extensions" "$LANGUAGE_ID" 2>/dev/null

IMAGE=$("$ROOT_DIR/utils.sh" "get_docker_image" "$LANGUAGE_ID" 2>/dev/null)

SEPARATOR=$("$ROOT_DIR/utils.sh" "print_separator")

PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR="$ROOT_DIR/runtimes/$LANGUAGE_ID/runtime"

COMMAND_PRINT_VERSION="
echo \">docker images\"
echo \"$IMAGE\"
echo \">./pharo Pharo.image --version\"
./pharo Pharo.image --version
echo \">./pharo Pharo.image printVersion\"
./pharo Pharo.image printVersion
echo \">./pharo Pharo.image eval \"SystemVersion current version\"\"
./pharo Pharo.image eval \"SystemVersion current version\"
"

COMMAND_COMPILE_AND_RUN_LANGUAGE_CODE="
./pharo Pharo.image st --quit \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/willyhorizont/runtime.st\" \"$PATH_TO_FILE_NAME_WITH_EXTENSION\"
"

if ! docker image inspect "$IMAGE" > /dev/null 2>&1; then
    docker build \
        -t "$IMAGE" \
        -f "$ROOT_DIR/docker/$LANGUAGE_ID/Dockerfile" \
        "$ROOT_DIR"
fi

docker run -i --rm \
    --entrypoint bash \
    -v "$ROOT_DIR:$ROOT_DIR" \
    "$IMAGE" \
    -c "
        $COMMAND_PRINT_VERSION

        echo \"$SEPARATOR\"

        $COMMAND_COMPILE_AND_RUN_LANGUAGE_CODE
    "
