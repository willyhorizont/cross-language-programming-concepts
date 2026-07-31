#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/v/willyhorizont/runtime/xl/xl.v"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">v version\"
v version
echo \">v --version\"
v --version
echo \">v -v\"
v -v
"

CCRLC="
cd \"$RD\"
v -path \"$RD/runtimes/v|@vlib|@vmodules\" \"$PTFNX\"
cd \"$PTFNXD\"
./$FN
rm -f $FN
"

CRLC="
cd \"$RD\"
v run -path \"$RD/runtimes/v|@vlib|@vmodules\" \"$PTFNX\"
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    docker build \
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
