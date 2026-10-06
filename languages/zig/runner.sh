#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

if [[ ".$FX" != "$XPECT_FX" ]]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTRFNX="$RD/runtimes/zig/willyhorizont/runtime/xl.zig"
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
echo \"docker images\"
echo \"$IMG\"
echo \"zig version\"
zig version
"

CCRLC="
cd \"$PTTFNXD\"
zig build-exe \"$TFN.$FX\"
./\"$TFN\"
rm -f \"$PTTFNXD/$TFN\"
"

CRLC="
cd \"$PTTFNXD\"
zig run \"$TFN.$FX\"
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    mkdir -p "$RD/tmp"

    FNX_ZIG=zig-x86_64-linux-0.16.0.tar.xz

    if [ ! -f "$RD/tmp/$FNX_ZIG" ]; then
        echo "Downloading $FNX_ZIG on host..."
        curl -L \
            --connect-timeout 60 \
            --retry 5 \
            --retry-delay 10 \
            --max-time 1800 \
            -o "$RD/tmp/$FNX_ZIG" "https://ziglang.org/download/0.16.0/zig-x86_64-linux-0.16.0.tar.xz"
    fi

    sudo systemctl enable --now docker.service
    sudo systemctl enable --now containerd.service
    docker build \
        --no-cache \
        -t "$IMG" \
        -f "$RD/docker/$LID/Dockerfile" \
        "$RD"
fi

docker run -i --rm \
    --entrypoint bash \
    -v "$HOME:$HOME" \
    -v "$PWD:$PWD" \
    -v "$RD:$RD" \
    -v "$SD:$SD" \
    "$IMG" \
    -c "
        $CPV

        echo \"$CCRLC\"

        echo \"$L\"

        $CCRLC
    "

sudo -p "$L
Enter password to stop docker container: " systemctl disable --now docker.service 2>/dev/null
sudo systemctl disable --now containerd.service
