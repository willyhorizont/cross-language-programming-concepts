#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

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
