#!/bin/bash

set -e
sudo -v

SD="$(dirname "$(realpath "$0")")"
RD="$(realpath "$SD")"
RN="$(basename "$RD")"

if ! command -v jq &> /dev/null; then
    echo "jq not installed. installing jq..."
    sudo apt update && sudo apt install -y jq
    sudo apt autoremove -y
fi

cat "$RD/tools/vscode-extensions-base.txt" | grep -v '^$' | sort -u | xargs -L 1 code --install-extension

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

TD="$RD/temp-downloads"
if [ ! -f /usr/local/bin/flashplayer ]; then
    echo "Downloading and installing Adobe Flash Player..."
    mkdir -p "$TD"
    wget -q -P "$TD" https://fpdownload.macromedia.com/pub/flashplayer/updaters/32/flash_player_sa_linux_debug.x86_64.tar.gz
    tar -xzf "$TD/flash_player_sa_linux_debug.x86_64.tar.gz" -C "$TD"
    sudo mv "$TD/flashplayerdebugger" /usr/local/bin/flashplayer
    sudo chmod +x /usr/local/bin/flashplayer
fi

if [ ! -f /usr/local/bin/ruffle ]; then
    echo "Downloading and installing Ruffle..."
    mkdir -p "$TD"
    wget -q -P "$TD" https://github.com/ruffle-rs/ruffle/releases/download/v0.3.0/ruffle-0.3.0-linux-x86_64.tar.gz
    tar -xzf "$TD/ruffle-0.3.0-linux-x86_64.tar.gz" -C "$TD"
    sudo mv "$TD/ruffle" /usr/local/bin/ruffle
    sudo chmod +x /usr/local/bin/ruffle
fi

code --install-extension bowlerhatllc.vscode-as3mxml
code --install-extension pleasedskin.smalltalk
code --install-extension DanielGavin.ols
code --install-extension NimLang.nimlang
code --install-extension ziglang.vscode-zig
code --install-extension Gleam.gleam
code --install-extension JakeBecker.elixir-ls
code --install-extension pgourlain.erlang
code --install-extension ocamllabs.ocaml-platform

eval "$RD/tools/vscode-extensions/vim9script-syntax-highlighter/install.sh"

rm -rf "$TD"
hash -r
