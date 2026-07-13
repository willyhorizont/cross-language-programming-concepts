#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

TFN="Main"
PTTFNX="$PTTFNXD/$TFN.$X"

mkdir -p "$PTTFNXD"
# cp -f "$PTFNX" "$PTTFNX"

if [ "$IS_RUNTIME_INSTALLED" != "TRUE" ]; then
    CIR="
        find \"$PTTFNXD\" -name \"*.java\" -print0 | xargs -0 javac -d \"$PTTFNXD\"
    "
    docker run -i --rm \
        --entrypoint bash \
        -v "$RD:$RD" \
        "$IMG" \
        -c "
            $CIR
        "
    echo "IS_RUNTIME_INSTALLED=\"TRUE\"" > "$LEF"
fi

cp -f "$PTFNX" "$PTTFNX"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">java -version\"
java -version
echo \">javac -version\"
javac -version
"

CRLC="
javac -cp \"$PTTFNXD\" -d \"$PTTFNXD\" \"$PTTFNX\"
java -cp \"$PTTFNXD\" \"$TFN\"
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

rm -f "$PTTFNXD/$TFN.class"
rm -f "$PTTFNXD/$TFN.java"
