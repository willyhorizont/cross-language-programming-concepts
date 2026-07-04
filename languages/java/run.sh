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
RN="$(basename "$RD")"

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

# "$RD/utils.sh" --setup-lang-specific-vscode-extensions $LID 2>/dev/null
code --install-extension "$RD/language-specific-extensions-installer.vsix" &> /dev/null

IMG=$("$RD/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/utils.sh" --print-sep)

PTTFNXD="$RD/runtimes/java"
TFN="Main"
PTTFNX="$PTTFNXD/$TFN.$X"

mkdir -p "$PTTFNXD"
cp -f "$PTFNX" "$PTTFNX"

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
javac -cp \"$PTTFNXD\" -d \"$PTTFNXD\" \"$PTTFNX\"
java -cp \"$PTTFNXD\" \"$TFN\"
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

rm -f "$PTTFNXD/$TFN.class"
rm -f "$PTTFNXD/$TFN.java"
