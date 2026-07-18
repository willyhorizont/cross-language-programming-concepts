#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/wolfram-language-script/willyhorizont/runtime/xl.wls"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">wolframscript -version\"
wolframscript -version
echo \">wolframscript --version\"
wolframscript --version
"

CRLC="
wolframscript -file \"$PTFNX\"
"

DCN="$LID-runner"

if [ -f "$PTDCNTFNX" ]; then
    TDCN=$(cat "$PTDCNTFNX")
    if [ ! -z "$TDCN" ] && [ "$TDCN" != "$DCN" ]; then
        docker rm -f "$TDCN" > /dev/null 2>&1
        rm -f "$PTDCNTFNX"
    fi
fi

if [ ! "$(docker ps -q -f name=$DCN)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=$DCN)" ]; then
        docker rm $DCN > /dev/null
    fi
    docker run -d \
        --name $DCN \
        --entrypoint "" \
        -v "$RD:$RD" \
        -v "$RD/runtimes/wolfram-language-script/Licensing:/home/wolframengine/.WolframEngine/Licensing" \
        "$IMG" \
        sleep infinity > /dev/null
    echo "$DCN" > "$PTDCNTFNX"
    sleep 2
fi

docker exec -i $DCN /bin/bash -c "
    $CPV

    echo \"$L\"

    $CRLC
"
