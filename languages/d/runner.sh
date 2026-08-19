#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

if [[ ".$FX" != "$XPECT_FX" ]]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTRFNX="$RD/runtimes/d/willyhorizont/runtime/xl.d"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">dmd --version\"
dmd --version
echo \">dub --version\"
dub --version
"

CCRLC="
cd \"$PTFNXD\"
dmd -i -I\"$RD/runtimes/d\" \"$PTFNX\"
./$FN
rm -f $FN.o
rm -f $FN
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    mkdir -p "$RD/tmp"

    FNX_DMD=dmd.2.112.0.linux.tar.xz

    if [ ! -f "$RD/tmp/$FNX_DMD" ]; then
        echo "Downloading $FNX_DMD on host..."
        curl -L \
            --connect-timeout 60 \
            --retry 5 \
            --retry-delay 10 \
            --max-time 1800 \
            -o "$RD/tmp/$FNX_DMD" "https://downloads.dlang.org/releases/2.x/2.112.0/dmd.2.112.0.linux.tar.xz"
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
