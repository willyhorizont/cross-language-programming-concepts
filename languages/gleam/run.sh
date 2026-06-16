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

PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR="$ROOT_DIR/runtimes/$LANGUAGE_NAME"
TARGET_FILE_NAME_WITHOUT_EXTENSION="main"
PATH_TO_TARGET_FILE_WITH_EXTENSION="$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION/src/$TARGET_FILE_NAME_WITHOUT_EXTENSION.$FILE_EXTENSION"

if [ "$IS_RUNTIME_INSTALLED" != "TRUE" ]; then
    COMMAND_INSTALL_RUNTIME="
        cd $PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR
        gleam new $TARGET_FILE_NAME_WITHOUT_EXTENSION
    "
    docker run -i --rm \
        --entrypoint bash \
        -v "$ROOT_DIR:$ROOT_DIR" \
        "$IMAGE" \
        -c "
            $COMMAND_INSTALL_RUNTIME
        "
    echo "IS_RUNTIME_INSTALLED=\"TRUE\"" > "$LANGUAGE_ENV_FILE"
fi

mkdir -p "$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR"
sudo cp -f "$PATH_TO_FILE_NAME_WITH_EXTENSION" "$PATH_TO_TARGET_FILE_WITH_EXTENSION"

COMMAND_PRINT_VERSION="
echo \">docker images\"
echo \"$IMAGE\"
echo \">gleam --version\"
gleam --version
echo \">erl -noshell -eval 'io:format(\\\"~s~n\\\", [erlang:system_info(system_version)]), halt().'\"
erl -noshell -eval 'io:format(\"~s~n\", [erlang:system_info(system_version)]), halt().'
echo \">cat /usr/local/lib/erlang/releases/29/OTP_VERSION\"
cat /usr/local/lib/erlang/releases/29/OTP_VERSION
"

COMMAND_RUN_LANGUAGE_CODE="
cd \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION\"
gleam run
"

docker run -i --rm \
    --entrypoint bash \
    -v "$ROOT_DIR:$ROOT_DIR" \
    "$IMAGE" \
    -c "
        $COMMAND_PRINT_VERSION

        echo \"$SEPARATOR\"

        $COMMAND_RUN_LANGUAGE_CODE
    "
