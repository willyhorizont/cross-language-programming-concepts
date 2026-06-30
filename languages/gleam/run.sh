#!/bin/bash

if [ -z "$1" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-extension>"
    exit 1
fi

PTFNX="$1"
PTFNXD="$(dirname "$PTFNX")"
FNX="$(basename "$PTFNX")"
FN="${FNX%.*}"
X="${FNX##*.}"

SD="$(dirname "$(realpath "$0")")"
LID="$(basename "$SD")"
RD="$(realpath "$SD/../..")"

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

"$RD/utils.sh" "setup_language_specific_vscode_extensions" "$LID" 2>/dev/null

IMG=$("$RD/utils.sh" "get_docker_image" "$LID" 2>/dev/null)

L=$("$RD/utils.sh" "print_separator")

PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR="$RD/runtimes/$LID"
TARGET_FILE_NAME_WITHOUT_EXTENSION="main"
PATH_TO_TARGET_FILE_WITH_EXTENSION="$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION/src/$TARGET_FILE_NAME_WITHOUT_EXTENSION.$X"

if [ "$IS_RUNTIME_INSTALLED" != "TRUE" ]; then
    CIR="
        cd $PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR
        gleam new $TARGET_FILE_NAME_WITHOUT_EXTENSION
    "
    docker run -i --rm \
        --entrypoint bash \
        -v "$RD:$RD" \
        "$IMG" \
        -c "
            $CIR
        "
    echo "IS_RUNTIME_INSTALLED=\"TRUE\"" > "$LEF"
fi

mkdir -p "$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR"
sudo cp -f "$PTFNX" "$PATH_TO_TARGET_FILE_WITH_EXTENSION"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">gleam --version\"
gleam --version
echo \">erl -noshell -eval 'io:format(\\\"~s~n\\\", [erlang:system_info(system_version)]), halt().'\"
erl -noshell -eval 'io:format(\"~s~n\", [erlang:system_info(system_version)]), halt().'
echo \">cat /usr/local/lib/erlang/releases/29/OTP_VERSION\"
cat /usr/local/lib/erlang/releases/29/OTP_VERSION
"

CRLC="
cd \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION\"
gleam run
"

docker run -i --rm \
    --entrypoint bash \
    -v "$RD:$RD" \
    "$IMG" \
    -c "
        $CPV

        echo \"$L\"

        $CRLC
    "
