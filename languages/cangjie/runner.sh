#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/cangjie/willyhorizont/runtime/xl.cj"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">cjc -v\"
cjc -v
echo \">cjc --version\"
cjc --version
"

CCRLC="
rm -rf \"$RD/runtimes/cangjie/target\"
mkdir -p \"$RD/runtimes/cangjie/target\"
cjc -p \"$RD/runtimes/cangjie/willyhorizont/runtime\" \
    --output-type=staticlib \
    --output-dir \"$RD/runtimes/cangjie/target\"
cjc --import-path \"$RD/runtimes/cangjie/target\" \
    -L \"$RD/runtimes/cangjie/target\" \
    -lwillyhorizont.runtime \
    \"$PTFNX\" \
    -o \"$RD/runtimes/cangjie/main\"
cd \"$RD/runtimes/cangjie\"
./main
rm -rf main target
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
