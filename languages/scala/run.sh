#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/elixir/willyhorizont/runtime/runtime.exs"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">scala-cli version\"
scala-cli version
"

CRLC="
cd \"$PTFNXD\"
scala-cli \"$FNX\"
"

docker run -i --rm \
    --entrypoint bash \
    -v scala-coursier-cache:/root/.cache/coursier \
    -v "$RD:$RD" \
    "$IMG" \
    -c "
        $CPV

        echo \"$L\"

        $CRLC
    "
