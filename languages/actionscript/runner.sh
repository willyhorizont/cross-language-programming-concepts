#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

if [[ ".$FX" != "$XPECT_FX" ]]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTRFNX="$RD/runtimes/actionscript/willyhorizont/runtime/Xl.as"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTTFNX="$RD/runtimes/actionscript/willyhorizont/runtime/Terminal.as"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTTFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    mkdir -p "$RD/tmp"

    FNX_JDK=jdk-7u80-linux-x64.tar.gz
    FNX_FLEX=apache-flex-sdk-4.16.1-bin.tar.gz
    FNX_SWC=playerglobal27.0.swc

    if [ ! -f "$RD/tmp/$FNX_JDK" ]; then
        FURL_JDK_ONE="https://repo.huaweicloud.com/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz"
        FURL_JDK_TWO="https://download.ithb.ac.id/downloads/Softwares/Developers/java/oracle/v7/jdk-7u80-linux-x64.tar.gz"
        echo "Downloading $FNX_JDK on host..."
        curl -L \
            --connect-timeout 60 \
            --retry 5 \
            --retry-delay 10 \
            --max-time 1800 \
            -o "$RD/tmp/$FNX_JDK" "$FURL_JDK_ONE"
    fi

    if [ ! -f "$RD/tmp/$FNX_FLEX" ]; then
        echo "Downloading $FNX_FLEX on host..."
        FURL_FLEX_ONE="https://dlcdn.apache.org/flex/4.16.1/binaries/apache-flex-sdk-4.16.1-bin.tar.gz"
        FURL_FLEX_TWO="https://archive.apache.org/dist/flex/4.16.1/binaries/apache-flex-sdk-4.16.1-bin.tar.gz"
        curl -L \
            --connect-timeout 60 \
            --retry 5 \
            --retry-delay 10 \
            --max-time 1800 \
            -o "$RD/tmp/$FNX_FLEX" "$FURL_FLEX_ONE"
    fi

    if [ ! -f "$RD/tmp/$FNX_SWC" ]; then
        echo "Downloading $FNX_SWC on host..."
        curl -L \
            --connect-timeout 60 \
            --retry 5 \
            --retry-delay 10 \
            --max-time 1800 \
            -o "$RD/tmp/$FNX_SWC" "https://github.com/nexussays/playerglobal/raw/refs/heads/master/27.0/playerglobal.swc"
    fi

    docker build \
        --no-cache \
        -t "$IMG" \
        -f "$RD/docker/$LID/Dockerfile" \
        "$RD"
fi

PTOFXD="$PTTFNXD/output"
PTOFNX="$PTOFXD/$FN.swf"
CFN="Main"
PTCFX="$PTTFNXD/$CFN.$FX"

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
