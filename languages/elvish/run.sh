#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">elvish -version\"
/bin/elvish -version
"

CRLC="
cd \"$PTFNXD\"
elvish \"$FNX\"
"

docker run -i --rm \
    -v "$RD:$RD" \
    "$IMG" \
    elvish -c "
        $CPV

        echo \"$L\"

        $CRLC
    "
