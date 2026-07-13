#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/zig/willyhorizont/runtime/xl.zig"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$LID"
    exit 1
fi

TFN="main"
PTTFNX="$PTTFNXD/$TFN.$X"

mkdir -p "$PTTFNXD"
cp -f "$PTFNX" "$PTTFNX"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">zig version\"
zig version
"

CCRLC="
cd \"$PTTFNXD\"
zig build-exe \"$TFN.$X\"
./\"$TFN\"
"

CRLC="
cd \"$PTTFNXD\"
zig run \"$TFN.$X\"
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
rm -f "$PTTFNXD/$TFN"
