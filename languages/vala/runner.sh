#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/vala/willyhorizont/runtime/xl.vala"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">valac --version\"
valac --version
"

CCRLC="
cd \"$RD\"
valac --pkg gee-0.8 \"$PTFNX\" \"$RD/runtimes/vala/willyhorizont/runtime/xl.vala\"
./$FN
rm -f $FN
"

CRLC="
cd \"$RD\"
valac --run --pkg gee-0.8 \"$PTFNX\" \"$RD/runtimes/vala/willyhorizont/runtime/xl.vala\"
"

SPRE="$L
/* [NOTICE] THIS IS NOT AN ERROR! The '__atomic_load' compiler warnings below are just GLib macro incompatibility with new GCC versions. Vala code is 100% WORK and compiled perfectly! */
"

SPOST="
/* [NOTICE] THIS IS NOT AN ERROR! The '__atomic_load' compiler warnings above are just GLib macro incompatibility with new GCC versions. Vala code is 100% WORK and compiled perfectly! */
$L"

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

        echo \"$SPRE\"

        export SEP=\"$SPOST\"

        $CCRLC
    "
