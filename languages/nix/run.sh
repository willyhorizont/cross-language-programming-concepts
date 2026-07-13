#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/nix/willyhorizont/runtime.nix"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$LID"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">nix --version\"
nix --version
echo \">nix-env --version\"
nix-env --version
echo \">nix-build --version\"
nix-build --version
echo \">nix-env --versionnix-build --version\"
nix-env --versionnix-build --version
"

CRLC="
cd \"$PTFNXD\"
nix-instantiate --eval --strict \"$FNX\"
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
