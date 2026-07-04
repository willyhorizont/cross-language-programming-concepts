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

PTRFNX="$RD/runtimes/go/willyhorizont/runtime/runtime.go"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-extension>"
    exit 1
fi

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

# "$RD/utils.sh" --setup-lang-specific-vscode-extensions $LID 2>/dev/null
code --install-extension "$RD/language-specific-extensions-installer.vsix" &> /dev/null

IMG=$("$RD/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/utils.sh" --print-sep)

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">go version\"
go version
"

CRLC="
cd \"$PTFNXD\"
go run \"$FNX\"
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
