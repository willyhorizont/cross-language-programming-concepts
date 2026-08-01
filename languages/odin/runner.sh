#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/odin/willyhorizont/runtime/xl.odin"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

TFN="main"
PTTFNX="$PTTFNXD/$TFN.$FX"

mkdir -p "$PTTFNXD"
cp -f "$PTFNX" "$PTTFNX"

# perl -i -pe 's/main :: proc\(\) \{/main :: proc() {\n    arena: virtual.Arena\n    err := virtual.arena_init_growing(\&arena)\n    if err != nil {\n        fmt.eprintln("Error: Failed initialize virtual memory arena.")\n        return\n    }\n    defer virtual.arena_destroy(\&arena) \n    context.allocator = virtual.arena_allocator(\&arena)/' "$PTTFNX"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">odin version\"
odin version
"

CCRLC="
cd \"$PTTFNXD\"
odin run .
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
