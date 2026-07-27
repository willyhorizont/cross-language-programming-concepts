#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/c3/willyhorizont/runtime/xl.c3"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">c3c -V\"
c3c -V
echo \">c3c --version\"
c3c --version
"

CCRLC="
rm -f \"$RD/runtimes/c3/output/main\"
mkdir -p \"$RD/runtimes/c3/output\"
c3c compile \"$PTFNX\" \"$PTRFNX\" -o \"$RD/runtimes/c3/output/main\"
cd \"$RD/runtimes/c3/output\"
./main
rm -f \"$RD/runtimes/c3/output/main\"
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
