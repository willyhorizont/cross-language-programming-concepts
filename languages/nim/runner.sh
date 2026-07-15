#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/nim/willyhorizont/runtime/xl.nim"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

TFN="main"
PTTFNX="$PTTFNXD/$TFN.$FX"

mkdir -p "$PTTFNXD"
cp -f "$PTFNX" "$PTTFNX"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">nim --version\"
nim --version
echo \">nim -v\"
nim -v
"

CRLC="
cd \"$PTTFNXD\"
nim c -r --hints:off \"$TFN.$FX\"
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

rm -f "$PTTFNXD/$TFN"
