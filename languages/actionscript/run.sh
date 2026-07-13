#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/actionscript/willyhorizont/runtime/Xl.as"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$LID"
    exit 1
fi

PTTFNX="$RD/runtimes/actionscript/willyhorizont/runtime/Terminal.as"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTTFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$LID"
    exit 1
fi

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    docker build \
        -t "$IMG" \
        -f "$RD/docker/$LID/Dockerfile" \
        "$RD"
fi

PTOFXD="$PTTFNXD/output"
PTOFNX="$PTOFXD/$FN.swf"
CFN="Main"
PTCFX="$PTTFNXD/$CFN.$X"

mkdir -p "$PTOFXD"
cp -f "$PTFNX" "$PTCFX"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">mxmlc -version\"
mxmlc -version
"

SW=800
SH=450
UN="$(whoami)"
UC="$(hostname)"
UD="$(pwd | sed "s|^$HOME|~|")"
C1="mkdir -p \"$PTOFXD\""
C2="cp -f \"$PTFNX\" \"$PTCFX\""
C3="mxmlc \"$PTRFNX\" -output \"$PTOFNX\""

CCLC="
rm -f \"$PTOFNX\"
mxmlc -source-path+=\"$PTTFNXD\" -default-size 800 450 -compiler.define=CONFIG::SCREEN_WIDTH,\"'${SW}'\" -compiler.define=CONFIG::SCREEN_HEIGHT,\"'${SH}'\" -compiler.define=CONFIG::USER_NAME,\"'${UN}'\" -compiler.define=CONFIG::USER_COMPUTER,\"'${UC}'\" -compiler.define=CONFIG::USER_PWD,\"'${UD}'\" -compiler.define=CONFIG::COMMAND_1,\"'${C1}'\" -compiler.define=CONFIG::COMMAND_2,\"'${C2}'\" -compiler.define=CONFIG::COMMAND_3,\"'${C3}'\" \"$PTRFNX\" -output \"$PTOFNX\"
echo \">SWF version:\"
java -jar /apache-flex-sdk/lib/swfdump.jar \"$PTOFNX\" | grep \"version=\"
echo \">Flash Player version:\"
grep \"<target-player>\" /apache-flex-sdk/frameworks/flex-config.xml
"

docker run -i --rm \
    --entrypoint bash \
    -v "$RD:$RD" \
    "$IMG" \
    -c "
        $CPV

        $CCLC
    "

echo "$L"

if [ -f "$PTOFNX" ]; then
    if command -v flashplayer &> /dev/null; then
        echo "opening using Adobe Flash Player..."
        flashplayer "$PTOFNX" >/dev/null 2>&1 &
        echo "if output not open automatically, open it here: \"$PTOFNX\""
    elif command -v ruffle &> /dev/null; then
        echo "opening using Ruffle..."
        ruffle "$PTOFNX" >/dev/null 2>&1 &
        echo "if output not open automatically, open it here: \"$PTOFNX\""
    else
        echo "if output not open automatically, open it here: \"$PTOFNX\""
    fi
fi
