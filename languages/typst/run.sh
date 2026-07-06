#!/bin/bash

SD="$(dirname "$(realpath "$0")")"
LID="$(basename "$SD")"
if [ -z "$1" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$LID"
    exit 1
fi

PTFNX="$1"
PTFNXD="$(dirname "$PTFNX")"
FNX="$(basename "$PTFNX")"
FN="${FNX%.*}"
X="${FNX##*.}"

RD="$(realpath "$SD/../..")"
RN="$(basename "$RD")"

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

IMG=$("$RD/tools/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/tools/utils.sh" --print-sep)

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">typst --version\"
typst --version
echo \">typst -V\"
typst -V
"

PTOFNXD="$RD/runtimes/typst/willyhorizont/output/$LID"
mkdir -p "$PTOFNXD"
PTOFNX="$PTOFNXD/$FN.pdf"
UN="$(whoami)"
UC="$(hostname)"
UPWD="$(pwd | sed "s|^$HOME|~|")"

CRLC="
cd \"$PTFNXD\"
typst compile --open --root \"$RD\" --input user-name=$UN --input user-computer=$UC --input user-pwd=$UPWD --input file-name-with-extension=\"$FNX\" \"$FNX\" \"$PTOFNX\"
echo \"if output not open automatically, open it here: \\\"$PTOFNX\\\"\"
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

if [ -f "$PTOFNX" ]; then
    code -r "$PTOFNX"
fi
