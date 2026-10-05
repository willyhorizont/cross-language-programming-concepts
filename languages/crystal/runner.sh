#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

if [[ ".$FX" != "$XPECT_FX" ]]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTRFNX="$RD/runtimes/crystal/willyhorizont/runtime/xl.cr"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \"docker images\"
echo \"$IMG\"
echo \"crystal --version\"
crystal --version
echo \"crystal -v\"
crystal -v
echo \"shards --version\"
shards --version
"

CCRLC="
crystal build \"$PTFNX\" -o \"$PTFNXD/$FN\"
cd \"$PTFNXD\"
./$FN
rm -f $FN
"

CRLC="
crystal run \"$PTFNX\"
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    mkdir -p "$RD/tmp"

    FNX_CRYSTAL=crystal-1.21.0-1-linux-x86_64-bundled.tar.gz

    if [ ! -f "$RD/tmp/$FNX_CRYSTAL" ]; then
        echo "Downloading $FNX_CRYSTAL on host..."
        curl -L \
            --connect-timeout 60 \
            --retry 5 \
            --retry-delay 10 \
            --max-time 1800 \
            -o "$RD/tmp/$FNX_CRYSTAL" "https://github.com/crystal-lang/crystal/releases/download/1.21.0/crystal-1.21.0-1-linux-x86_64-bundled.tar.gz"
    fi

    sudo systemctl start docker
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
Enter password to stop docker container: " systemctl stop --no-block docker.service containerd.service 2>/dev/null
