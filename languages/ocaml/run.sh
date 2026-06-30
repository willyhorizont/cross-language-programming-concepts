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
TARGET_FILE_NAME_WITHOUT_EXTENSION="main"
PATH_TO_TARGET_FILE_WITH_EXTENSION="$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION.$X"

mkdir -p "$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR"
cp -f "$PTFNX" "$PATH_TO_TARGET_FILE_WITH_EXTENSION"

if [ "$IS_RUNTIME_INSTALLED" != "TRUE" ]; then
    CIR="
        ocamlopt -c \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/willyhorizont.ml\"
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

CPV="
echo \">docker images\"
echo \"$IMG\"
eval \$(opam env)
echo \">ocamlc --version\"
ocamlc --version
"

CRLC="
ocamlopt -I \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR\" -o \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION\" \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/willyhorizont.cmx\" \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION.$X\"
cd \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR\"
./$TARGET_FILE_NAME_WITHOUT_EXTENSION
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

rm -f "$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION.cmi"
rm -f "$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION.cmx"
rm -f "$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION.ml"
rm -f "$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION.o"
rm -f "$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION"
