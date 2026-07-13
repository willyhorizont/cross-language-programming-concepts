#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/elvish/willyhorizont/runtime/xl.elv"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$LID"
    exit 1
fi

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
