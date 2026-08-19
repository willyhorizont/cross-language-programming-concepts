#!/bin/bash

set -e
sudo -v

SD="$(dirname "$(realpath "$0")")"
RD="$(realpath "$SD")"
RN="$(basename "$RD")"

if ! command -v jq &> /dev/null; then
    echo "jq not installed. Installing jq..."
    if command -v dnf &> /dev/null; then
        (sudo dnf check-update || true) && sudo dnf install -y jq
        sudo dnf autoremove -y
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y jq
        sudo apt autoremove -y
    else
        echo "Error: Please use Debian/based distro or Fedora/based distro."
        exit 1
    fi
fi

if [ -f "$RD/tools/vscode-extensions-base.txt" ]; then
    echo "installing essential extensions..."
    cat "$RD/tools/vscode-extensions-base.txt" | grep -v '^$' | sort -u | xargs -L 1 code --install-extension
fi

echo "installing essential libraries..."
if command -v dnf &> /dev/null; then
    FPDL=("curl" "gtk2" "nss")
    MFPDL=()
    for FPD in "${FPDL[@]}"; do
        if ! rpm -q "$FPD" >/dev/null 2>&1; then
            MFPDL+=("$FPD")
        fi
    done
    if [ ${#MFPDL[@]} -ne 0 ]; then
        (sudo dnf check-update || true)
        sudo dnf install "${MFPDL[@]}" -y --skip-unavailable
        sudo dnf autoremove -y
    fi
elif command -v apt &> /dev/null; then
    FPDL=("curl" "wget" "x11-apps" "libnss3" "libvdpau-va-gl1")
    if apt-cache show libgtk2.0-0t64 &>/dev/null; then
        FPDL+=("libgtk2.0-0t64:amd64")
    else
        FPDL+=("libgtk2.0-0")
    fi
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
else
    echo "Error: Please use Debian/based distro or Fedora/based distro."
    exit 1
fi

TD="$RD/tmp"
mkdir -p "$TD"

if [ ! -f /usr/local/bin/flashplayer ]; then
    PTFNX_FLASH="$TD/flash_player_sa_linux_debug.x86_64.tar.gz"
    if [ -f "$PTFNX_FLASH" ]; then
        echo "Local Adobe Flash Player archive found in tmp. Skipping download."
    else
        echo "Downloading Adobe Flash Player..."
        curl -L -o "$PTFNX_FLASH" https://fpdownload.macromedia.com/pub/flashplayer/updaters/32/flash_player_sa_linux_debug.x86_64.tar.gz
    fi
    if [ -f "$PTFNX_FLASH" ]; then
        tar -xzf "$PTFNX_FLASH" -C "$TD"
        sudo mv "$TD/flashplayerdebugger" /usr/local/bin/flashplayer
        sudo chmod +x /usr/local/bin/flashplayer
    else
        echo "Error: Can not install Adobe Flash Player."
        exit 1
    fi
fi

if [ ! -f /usr/local/bin/ruffle ]; then
    PTFNX_RUFFLE="$TD/ruffle-0.3.0-linux-x86_64.tar.gz"
    if [ -f "$PTFNX_RUFFLE" ]; then
        echo "Local Ruffle archive found in tmp. Skipping download."
    else
        echo "Downloading Ruffle..."
        curl -L -o "$PTFNX_RUFFLE" https://github.com/ruffle-rs/ruffle/releases/download/v0.3.0/ruffle-0.3.0-linux-x86_64.tar.gz
    fi
    if [ -f "$PTFNX_RUFFLE" ]; then
        tar -xzf "$PTFNX_RUFFLE" -C "$TD"
        sudo mv "$TD/ruffle" /usr/local/bin/ruffle
        sudo chmod +x /usr/local/bin/ruffle
    else
        echo "Error: Can not install Ruffle."
        exit 1
    fi
fi

hash -r

sudo usermod -aG docker $USER
newgrp docker

echo "setup environment finished"
