#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/crystal/willyhorizont/runtime/xl.cr"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">crystal --version\"
crystal --version
echo \">crystal -v\"
crystal -v
echo \">shards --version\"
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
