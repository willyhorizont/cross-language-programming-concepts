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
echo \">c3c --version\"
c3c --version
echo \">c3c -V\"
c3c -V
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
    mkdir -p "$RD/tmp"

    FNX_C3=c3-v0.8.2-linux-static.tar.gz

    if [ ! -f "$RD/tmp/$FNX_C3" ]; then
        echo "Downloading $FNX_C3 on host..."
        curl -L \
            --connect-timeout 60 \
            --retry 5 \
            --retry-delay 10 \
            --max-time 1800 \
            -o "$RD/tmp/$FNX_C3" "https://github.com/c3lang/c3c/releases/download/v0.8.2/c3-linux-static.tar.gz"
    fi

    docker build \
        --no-cache \
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
