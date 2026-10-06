#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

if [[ ".$FX" != "$XPECT_FX" ]]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTRFNX="$RD/runtimes/tcl/willyhorizont/runtime/xl.tcl"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \"docker images\"
echo \"$IMG\"
echo \"echo \\\"puts [info patchlevel]\\\" | tclsh\"
echo \"puts [info patchlevel]\" | tclsh
"

CRLC="
cd \"$PTFNXD\"
tclsh \"$FNX\"
"

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
Enter password to stop docker container: " systemctl disable --now docker.service 2>/dev/null
sudo systemctl disable --now containerd.service
