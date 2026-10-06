#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

if [[ ".$FX" != "$XPECT_FX" ]]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTRFNX="$RD/runtimes/c-sharp/willyhorizont/runtime/Xl.cs"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

JSON_DIR="$RD/tmp"
JSON_FILE_NAME="dotnet-release-10.0.10.json"
JSON_FILE="$JSON_DIR/$JSON_FILE_NAME"
mkdir -p "$JSON_DIR"

if [ ! -f "$JSON_FILE" ]; then
    echo "Downloading $JSON_FILE_NAME to $JSON_DIR"
    curl -sL "https://raw.githubusercontent.com/dotnet/core/refs/heads/main/release-notes/10.0/10.0.10/release.json" -o "$JSON_FILE"
fi

CVER="cat \"$JSON_FILE\" | jq -r '.release.sdks[] | select(.version == \"10.0.302\") | .\"csharp-version\"'"

RVER=$(eval "$CVER")

CPV="
echo \"docker images\"
echo \"$IMG\"
echo \"$CVER\"
echo \"$RVER\"
"

CCRLC="
rm -rf \"$PTTFNXD/obj\"
rm -rf \"$PTTFNXD/output\"
cp -f \"$PTFNX\" \"$PTTFNXD/Main.cs\"
cd \"$PTTFNXD\"
dotnet build \"Main.csproj\" -c Release --verbosity quiet
cd \"$PTTFNXD/output/net10.0\"
./Main
cd \"$RD\"
rm -rf \"$PTTFNXD/output\"
rm -rf \"$PTTFNXD/obj\"
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    mkdir -p "$RD/tmp"

    FNX_DOTNET=dotnet-sdk-10.0.302-linux-x64.tar.gz

    if [ ! -f "$RD/tmp/$FNX_DOTNET" ]; then
        echo "Downloading $FNX_DOTNET on host..."
        curl -L \
            --connect-timeout 60 \
            --retry 5 \
            --retry-delay 10 \
            --max-time 1800 \
            -o "$RD/tmp/$FNX_DOTNET" "https://builds.dotnet.microsoft.com/dotnet/Sdk/10.0.302/dotnet-sdk-10.0.302-linux-x64.tar.gz"
    fi

    sudo systemctl enable --now docker.service
    sudo systemctl enable --now containerd.service
    docker build \
        --no-cache \
        -t "$IMG" \
        -f "$RD/docker/c-sharp-and-visual-basic-dot-net/Dockerfile" \
        "$RD"
fi

docker run -i --rm \
    --entrypoint bash \
    -v "$HOME:$HOME" \
    -v "$PWD:$PWD" \
    -v "$RD:$RD" \
    -v "$SD:$SD" \
    "$IMG" \
    -c "
        $CPV

        echo \"$CCRLC\"

        echo \"$L\"

        $CCRLC
    "

sudo -p "$L
Enter password to stop docker container: " systemctl disable --now docker.service 2>/dev/null
sudo systemctl disable --now containerd.service
