#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/go/willyhorizont/runtime/xl.go"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">go version\"
go version
"

CRLC="
cd \"$PTFNXD\"
go run \"$FNX\"
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
