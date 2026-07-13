#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">kotlinc -version\"
kotlinc -version
echo \">kotlin -version\"
kotlin -version
"

CRLC="
cd \"$PTFNXD\"
kotlinc \"$FNX\" -include-runtime -d \"$FN.jar\"
kotlin \"$FN.jar\"
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

rm -f "$PTFNXD/$FN.jar"
