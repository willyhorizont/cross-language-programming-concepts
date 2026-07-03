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

# "$RD/utils.sh" "setup_language_specific_vscode_extensions" "$LID" 2>/dev/null
code --install-extension "$RD/language-specific-extensions-installer.vsix"

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

CRO="
TD=\"$RD/temp-downloads\"
sudo apt update && sudo apt install wget x11-apps libgtk2.0-0t64:amd64 libnss3 -y

if [ ! -f /usr/local/bin/flashplayer ]; then
    echo \"Installing Adobe Flash Player dependencies...\"
    sudo apt update && sudo apt install libvdpau-va-gl1 -y
    echo \"Downloading and installing Adobe Flash Player...\"
    mkdir -p \"\$TD\"
    wget -q -P \"\$TD\" https://fpdownload.macromedia.com/pub/flashplayer/updaters/32/flash_player_sa_linux_debug.x86_64.tar.gz
    tar -xzf \"\$TD/flash_player_sa_linux_debug.x86_64.tar.gz\" -C \"\$TD\"
    sudo mv \"\$TD/flashplayerdebugger\" /usr/local/bin/flashplayer
    sudo chmod +x /usr/local/bin/flashplayer
    rm -rf \"\$TD\"
fi

if [ -f \"$PTOFXD/$FN.swf\" ]; then
    # if false; then
    if command -v flashplayer &> /dev/null; then
        echo \"opening using Adobe Flash Player...\"
        flashplayer \"$PTOFXD/$FN.swf\" >/dev/null 2>&1 &
        echo \"if output not open automatically, open it here: \"$PTOFXD/$FN.swf\"\"
    else
        echo \"Adobe Flash Player not opening or failed to download...\"
        if ! command -v ruffle &> /dev/null; then
            echo \"Downloading and installing Ruffle...\"
            mkdir -p \"\$TD\"
            wget -q -P \"\$TD\" https://github.com/ruffle-rs/ruffle/releases/download/v0.3.0/ruffle-0.3.0-linux-x86_64.tar.gz
            tar -xzf \"\$TD/ruffle-0.3.0-linux-x86_64.tar.gz\" -C \"\$TD\"
            sudo mv \"\$TD/ruffle\" /usr/local/bin/ruffle
            sudo chmod +x /usr/local/bin/ruffle
            rm -rf \"\$TD\"
        fi

        echo \"opening using Ruffle...\"
        ruffle \"$PTOFXD/$FN.swf\" >/dev/null 2>&1 &
        echo \"if output not open automatically, open it here: \"$PTOFXD/$FN.swf\"\"
    fi
fi
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

        $CCLC
    "

rm -f "$PTIFX"

echo "$L"

eval "$CRO"
