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
RN="$(basename "$RD")"

PTRFNX="$RD/runtimes/actionscript/runtime/willyhorizont/Xl.as"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-extension>"
    exit 1
fi

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

code --install-extension "$RD/language-specific-extensions-installer.vsix" &> /dev/null

IMG=$("$RD/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/utils.sh" --print-sep)

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    docker build \
        -t "$IMG" \
        -f "$RD/docker/$LID/Dockerfile" \
        "$RD"
fi

TD="$RD/temp-downloads"
FPDL=("wget" "x11-apps" "libgtk2.0-0t64:amd64" "libnss3" "libvdpau-va-gl1")
MFPDL=()
for FPD in "${FPDL[@]}"; do
    if ! dpkg -s "$FPD" >/dev/null 2>&1; then
        MFPDL+=("$FPD")
    fi
done
if [ ${#MFPDL[@]} -ne 0 ]; then
    sudo apt update && sudo apt install "${MFPDL[@]}" -y
    sudo apt autoremove -y
fi

if [ ! -f /usr/local/bin/flashplayer ]; then
    echo "Downloading and installing Adobe Flash Player..."
    mkdir -p "$TD"
    wget -q -P "$TD" https://fpdownload.macromedia.com/pub/flashplayer/updaters/32/flash_player_sa_linux_debug.x86_64.tar.gz
    tar -xzf "$TD/flash_player_sa_linux_debug.x86_64.tar.gz" -C "$TD"
    sudo mv "$TD/flashplayerdebugger" /usr/local/bin/flashplayer
    sudo chmod +x /usr/local/bin/flashplayer
    rm -rf "$TD"
    hash -r
fi
if ! /usr/local/bin/flashplayer -v &> /dev/null; then
    echo "Adobe Flash Player not opening or failed to download..."
    if [ ! -f /usr/local/bin/ruffle ]; then
        echo "Downloading and installing Ruffle..."
        mkdir -p "$TD"
        wget -q -P "$TD" https://github.com/ruffle-rs/ruffle/releases/download/v0.3.0/ruffle-0.3.0-linux-x86_64.tar.gz
        tar -xzf "$TD/ruffle-0.3.0-linux-x86_64.tar.gz" -C "$TD"
        sudo mv "$TD/ruffle" /usr/local/bin/ruffle
        sudo chmod +x /usr/local/bin/ruffle
        rm -rf "$TD"
        hash -r
    fi
fi

PTRD="$RD/runtimes/$LID"
PTOFXD="$PTRD/output"
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

SW=1280
SH=720
UN="$(whoami)"
UC="$(hostname)"
UD="$(pwd | sed "s|^$HOME|~|")"
C1="mkdir -p \"$PTOFXD\""
C2="cp -f \"$PTFNX\" \"$PTIFX\""
C3="mxmlc \"$PTRFX\" -output \"$PTOFXD/$FN.swf\""

CCLC="
mxmlc -source-path+=\"$PTRD\" -default-size 800 450 -compiler.define=CONFIG::SCREEN_WIDTH,\"'${SW}'\" -compiler.define=CONFIG::SCREEN_HEIGHT,\"'${SH}'\" -compiler.define=CONFIG::USER_NAME,\"'${UN}'\" -compiler.define=CONFIG::USER_COMPUTER,\"'${UC}'\" -compiler.define=CONFIG::USER_PWD,\"'${UD}'\" -compiler.define=CONFIG::COMMAND_1,\"'${C1}'\" -compiler.define=CONFIG::COMMAND_2,\"'${C2}'\" -compiler.define=CONFIG::COMMAND_3,\"'${C3}'\" \"$PTRFX\" -output \"$PTOFXD/$FN.swf\"
echo \">SWF version:\"
java -jar /apache-flex-sdk/lib/swfdump.jar \"$PTOFXD/$FN.swf\" | grep \"version=\"
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

rm -f "$PTIFX"

echo "$L"

if [ -f "$PTOFXD/$FN.swf" ]; then
    if command -v flashplayer &> /dev/null; then
        echo "opening using Adobe Flash Player..."
        flashplayer "$PTOFXD/$FN.swf" >/dev/null 2>&1 &
        echo "if output not open automatically, open it here: \"$PTOFXD/$FN.swf\""
    elif command -v ruffle &> /dev/null; then
        echo "opening using Ruffle..."
        ruffle "$PTOFXD/$FN.swf" >/dev/null 2>&1 &
        echo "if output not open automatically, open it here: \"$PTOFXD/$FN.swf\""
    else
        echo "if output not open automatically, open it here: \"$PTOFXD/$FN.swf\""
    fi
fi
