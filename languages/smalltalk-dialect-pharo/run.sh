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

PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR="$RD/runtimes/$LID/runtime"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">./pharo Pharo.image --version\"
./pharo Pharo.image --version
echo \">./pharo Pharo.image printVersion\"
./pharo Pharo.image printVersion
echo \">./pharo Pharo.image eval \"SystemVersion current version\"\"
./pharo Pharo.image eval \"SystemVersion current version\"
"

COMMAND_COMPILE_AND_RUN_LANGUAGE_CODE="
./pharo Pharo.image st --quit \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/willyhorizont/runtime.st\" \"$PTFNX\"
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    docker build \
        -t "$IMG" \
        -f "$RD/docker/$LID/Dockerfile" \
        "$RD"
fi

docker run -i --rm \
    --entrypoint bash \
    -v "$RD:$RD" \
    "$IMG" \
    -c "
        $CPV

        echo \"$L\"

        $COMMAND_COMPILE_AND_RUN_LANGUAGE_CODE
    "
