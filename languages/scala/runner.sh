#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/scala/willyhorizont/runtime/xl.scala"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">scala-cli version\"
scala-cli version
"

CRLC="
cp -f \"$PTFNX\" \"$PTTFNXD/main.scala\"
cd \"$PTTFNXD\"
scala-cli run .
"

DCN="scala-runner"

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
        -v scala-coursier-cache:/root/.cache/coursier \
        -v "$RD:$RD" \
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
