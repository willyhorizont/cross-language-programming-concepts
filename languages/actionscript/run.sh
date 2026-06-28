#!/bin/bash

if [ -z "$1" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-extension>"
    exit 1
fi

PTFNX="$1"
PTFNXD="$(dirname "$PTFNX")"
FNX="$(basename "$PTFNX")"
FN="${FNX%.*}"
X="${FNX##*.}"

SD="$(dirname "$(realpath "$0")")"
LID="$(basename "$SD")"
RD="$(realpath "$SD/../..")"

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

"$RD/utils.sh" "setup_language_specific_vscode_extensions" "$LID" 2>/dev/null

IMG=$("$RD/utils.sh" "get_docker_image" "$LID" 2>/dev/null)

L=$("$RD/utils.sh" "print_separator")

PTRD="$RD/runtimes/$LID"
PTOFXD="$PTRD/output"
PTRFXD="$PTRD/runtime/willyhorizont"
RFN="Runtime"
PTRFX="$PTRFXD/$RFN.$X"

if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-extension>"
    exit 1
fi

IFN="Program"
PTIFX="$PTRD/$IFN.$X"

mkdir -p "$PTOFXD"
cp -f "$PTFNX" "$PTIFX"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">mxmlc -version\"
mxmlc -version
"
SW=$(xrandr | grep '*' | awk '{print $1}' | cut -d'x' -f1)
SH=$(xrandr | grep '*' | awk '{print $1}' | cut -d'x' -f2)
UN="$(whoami)"
UC="$(hostname)"
UD="$(pwd | sed "s|^$HOME|~|")"
C1="mkdir -p \"$PTOFXD\""
C2="cp -f \"$PTFNX\" \"$PTIFX\""
C3="mxmlc \"$PTRFX\" -output \"$PTOFXD/$FN.swf\""
CCRLC="
mxmlc -source-path+=\"$PTRD\" -default-size 800 450 -compiler.define=CONFIG::SCREEN_WIDTH,\"'${SW}'\" -compiler.define=CONFIG::SCREEN_HEIGHT,\"'${SH}'\" -compiler.define=CONFIG::USER_NAME,\"'${UN}'\" -compiler.define=CONFIG::USER_COMPUTER,\"'${UC}'\" -compiler.define=CONFIG::USER_PWD,\"'${UD}'\" -compiler.define=CONFIG::COMMAND_1,\"'${C1}'\" -compiler.define=CONFIG::COMMAND_2,\"'${C2}'\" -compiler.define=CONFIG::COMMAND_3,\"'${C3}'\" \"$PTRFX\" -output \"$PTOFXD/$FN.swf\"
echo \">SWF version:\"
java -jar /apache-flex-sdk/lib/swfdump.jar \"$PTOFXD/$FN.swf\" | grep \"version=\"
echo \">Flash Player version:\"
grep \"<target-player>\" /apache-flex-sdk/frameworks/flex-config.xml
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    docker build \
        -t "$IMG" \
        -f "$RD/docker/$LID/Dockerfile" \
        "$RD"
fi

docker run -i --rm \
    --entrypoint bash \
    -v "$RD:$RD" \
    "$IMG" \
    -c "
        $CPV

        echo \"$L\"

        $CCRLC
    "

rm -f "$PTIFX"
