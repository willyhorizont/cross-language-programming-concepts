#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/powershell/willyhorizont/runtime/xl.ps1"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">pwsh --version\"
pwsh --version
"

CRLC="
cd \"$PTFNXD\"
pwsh \"$FNX\"
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
