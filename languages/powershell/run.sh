#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">pwsh --version\"
pwsh --version
"

CRLC="
cd \"$PTFNXD\"
pwsh \"$FNX\"
"

docker run -i --rm \
    --entrypoint bash \
    -v "$RD:$RD" \
    "$IMG" \
    -c "
        $CPV

        echo \"$L\"

        $CRLC
    "
