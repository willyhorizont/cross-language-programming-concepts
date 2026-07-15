#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/vimscript/willyhorizont/runtime/xl.vim"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">vim --version 2>/dev/null | head -n 2\"
vim --version 2>/dev/null | head -n 2
"

CRLC="
cd \"$PTFNXD\"
vim -e -s -c \"source $PTFNX\" -c \"echomsg ''\" -c \"verbose messages\" -c \"qa!\"
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
