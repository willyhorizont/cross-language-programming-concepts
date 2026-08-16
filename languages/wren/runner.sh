#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/wren/willyhorizont/runtime/xl.wren"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">wren --version\"
wren --version
"

CRLC="
wren \"$PTFNX\"
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    mkdir -p "$RD/tmp"

    FNX_WREN=wren-cli-linux-0.4.0.zip

    if [ ! -f "$RD/tmp/$FNX_WREN" ]; then
        echo "Downloading $FNX_WREN on host..."
        curl -L \
            --connect-timeout 60 \
            --retry 5 \
            --retry-delay 10 \
            --max-time 1800 \
            -o "$RD/tmp/$FNX_WREN" "https://github.com/wren-lang/wren-cli/releases/download/0.4.0/wren-cli-linux-0.4.0.zip"
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

        $CRLC
    "
