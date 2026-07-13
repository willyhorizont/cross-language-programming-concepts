#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">echo \\\"puts [info patchlevel]\\\" | tclsh\"
echo \"puts [info patchlevel]\" | tclsh
"

CRLC="
cd \"$PTFNXD\"
tclsh \"$FNX\"
"

docker run -i --rm \
    --entrypoint bash \
    -v "$RD:$RD" \
    "$IMG" \
    -c "
        $CPV

        echo \"$L\"

        $CRLC
    "
