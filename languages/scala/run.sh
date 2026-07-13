#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

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
