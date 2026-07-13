#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">g++ -std=c++23 \"$FNX\" -o \"$FN\"\"
"

CRLC="
cd \"$PTFNXD\"
g++ -std=c++23 \"$FNX\" -o \"$FN\"
./$FN
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

rm -f "$PTFNXD/$FN"