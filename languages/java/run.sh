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

PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR="$RD/runtimes/java"
TARGET_FILE_NAME_WITHOUT_EXTENSION="Main"
PATH_TO_TARGET_FILE_WITH_EXTENSION="$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION.$X"

mkdir -p "$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR"
cp -f "$PTFNX" "$PATH_TO_TARGET_FILE_WITH_EXTENSION"

if [ "$IS_RUNTIME_INSTALLED" != "TRUE" ]; then
    CIR="
        find \"$RD/runtimes/$LID\" -name \"*.java\" -print0 | xargs -0 javac -d \"$RD/runtimes/$LID\"
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
echo \">java -version\"
java -version
echo \">javac -version\"
javac -version
"

CRLC="
javac -cp \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR\" -d \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR\" \"$PATH_TO_TARGET_FILE_WITH_EXTENSION\"
java -cp \"$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR\" \"$TARGET_FILE_NAME_WITHOUT_EXTENSION\"
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

rm -f "$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION.class"
rm -f "$PATH_TO_TARGET_FILE_WITH_EXTENSION_DIR/$TARGET_FILE_NAME_WITHOUT_EXTENSION.java"
