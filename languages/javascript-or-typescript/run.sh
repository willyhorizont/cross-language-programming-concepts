#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/javascript-or-typescript/willyhorizont/runtime.js"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$LID"
    exit 1
fi

CPV="
npm install -g npm@latest --no-fund --no-audit --silent
echo \">docker images\"
echo \"$IMG\"
echo \">node --version\"
node --version
echo \">npm --version\"
npm --version
"

CRLC="
cd \"$PTFNXD\"
node \"$FNX\"
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