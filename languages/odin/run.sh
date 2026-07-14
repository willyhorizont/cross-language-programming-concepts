#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/odin/willyhorizont/runtime/xl.odin"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$FX"
    exit 1
fi

TFN="main"
PTTFNX="$PTTFNXD/$TFN.$FX"

mkdir -p "$PTTFNXD"
cp -f "$PTFNX" "$PTTFNX"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">odin version\"
odin version
"

CCRLC="
cd \"$PTTFNXD\"
odin run .
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

        $CCRLC
    "
