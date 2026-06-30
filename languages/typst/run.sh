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

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">typst --version\"
typst --version
echo \">typst -V\"
typst -V
"

mkdir -p \"$PATH_TO_OUTPUT_FILE_NAME_WITH_EXTENSION_DIR\"
PATH_TO_OUTPUT_FILE_NAME_WITH_EXTENSION_DIR="$RD/runtimes/typst/willyhorizont/output/$LID"
PATH_TO_OUTPUT_FILE_NAME_WITH_EXTENSION="$PATH_TO_OUTPUT_FILE_NAME_WITH_EXTENSION_DIR/$FN.pdf"
USER_NAME="$(whoami)"
USER_COMPUTER="$(hostname)"
USER_PWD="$(pwd | sed "s|^$HOME|~|")"

CRLC="
cd \"$PTFNXD\"
typst compile --open --root \"$RD\" --input user-name=$USER_NAME --input user-computer=$USER_COMPUTER --input user-pwd=$USER_PWD --input file-name-with-extension=\"$FNX\" \"$FNX\" \"$PATH_TO_OUTPUT_FILE_NAME_WITH_EXTENSION\"
echo \"if output not open automatically, open it here: \\\"$PATH_TO_OUTPUT_FILE_NAME_WITH_EXTENSION\\\"\"
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

if [ -f "$PATH_TO_OUTPUT_FILE_NAME_WITH_EXTENSION" ]; then
    code -r "$PATH_TO_OUTPUT_FILE_NAME_WITH_EXTENSION"
fi
