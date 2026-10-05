#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

if [[ ".$FX" != "$XPECT_FX" ]]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTRFNX="$RD/runtimes/pike/willyhorizont/runtime/xl.pike"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \"docker images\"
echo \"$IMG\"
echo \"pike --version\"
pike --version
"

CRLC="
pike \"$PTFNX\"
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    mkdir -p "$RD/tmp"

    FNX_PIKE=Pike-v8.0.1956.tar.gz

    if [ ! -f "$RD/tmp/$FNX_PIKE" ]; then
        echo "Downloading $FNX_PIKE on host..."
        curl -L \
            --connect-timeout 60 \
            --retry 5 \
            --retry-delay 10 \
            --max-time 1800 \
            -o "$RD/tmp/$FNX_PIKE" "https://pike.lysator.liu.se/pub/pike/latest-stable/Pike-v8.0.1956.tar.gz"
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

        echo \"$CRLC\"

        echo \"$L\"

        $CRLC
    "

sudo -p "$L
Enter password to stop docker container: " systemctl stop --no-block docker.service containerd.service 2>/dev/null
