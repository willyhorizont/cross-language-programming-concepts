#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/visual-basic-dot-net/willyhorizont/runtime/Xl.vb"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

DN_INFO="
.NET SDK: 10.0.302
ASP.NET Core Runtime: 10.0.10
Visual Studio support: Visual Studio 2026 (v18.8)
Included in: Visual Studio 18.8.0
Included runtimes: .NET Runtime 10.0.10, ASP.NET Core Runtime 10.0.10, .NET Desktop Runtime 10.0.10
Language support: C# 14.0, F# 10.0, Visual Basic 17.13
more info: https://dotnet.microsoft.com/en-us/download/dotnet/10.0
"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">dotnet --info\"
echo \"$DN_INFO\"
"

CCRLC="
rm -rf \"$PTTFNXD/obj\"
rm -rf \"$PTTFNXD/output\"
cp -f \"$PTFNX\" \"$PTTFNXD/Main.vb\"
cd \"$PTTFNXD\"
dotnet build \"Main.vbproj\" -c Release --verbosity quiet
cd \"$PTTFNXD/output/net10.0\"
./Main
cd \"$RD\"
rm -rf \"$PTTFNXD/output\"
rm -rf \"$PTTFNXD/obj\"
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    docker build \
        -t "$IMG" \
        -f "$RD/docker/c-sharp-and-visual-basic-dot-net/Dockerfile" \
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
