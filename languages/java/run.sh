#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

TFN="Main"
PTTFNX="$PTTFNXD/$TFN.$FX"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">java -version\"
java -version
echo \">javac -version\"
javac -version
"

CRLC="
cp -f \"$PTFNX\" \"$PTTFNX\"
find \"$PTTFNXD\" -name \"*.class\" -delete
find \"$PTTFNXD\" -name \"*.java\" -print0 | xargs -0 javac -d \"$PTTFNXD\"
javac -cp \"$PTTFNXD\" -d \"$PTTFNXD\" \"$PTTFNX\"
java -cp \"$PTTFNXD\" \"$TFN\"
find \"$PTTFNXD\" -name \"*.class\" -delete
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
