#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/cangjie/willyhorizont/runtime/Xl.cj"
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
    -lwillyhorizont.runtime.Xl \
    \"$PTFNX\" \
    -o \"$RD/runtimes/cangjie/main\"
cd \"$RD/runtimes/cangjie\"
./main
rm -rf main target
find \"$RD/runtimes/cangjie\" -name \"*.cjo\" -delete
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    mkdir -p "$RD/tmp"

    FNX_CANGJIE=cangjie-sdk-linux-x64-1.1.3.tar.gz

    if [ ! -f "$RD/tmp/$FNX_CANGJIE" ]; then
        echo "Downloading $FNX_CANGJIE on host..."
        curl -L \
            --connect-timeout 60 \
            --retry 5 \
            --retry-delay 10 \
            --max-time 1800 \
            -o "$RD/tmp/$FNX_CANGJIE" "https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-1.1.3.tar.gz&objectKey=6a19349d21f5a8178d6fd22b"
    fi

    docker build \
        --no-cache \
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
