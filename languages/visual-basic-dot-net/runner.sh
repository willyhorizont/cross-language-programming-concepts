#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/visual-basic-dot-net/willyhorizont/runtime/Xl.vb"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTVBC="/usr/share/dotnet/sdk/9.0.316/Roslyn/bincore/vbc.dll"

CPV_1="
echo \">docker images\"
echo \"$IMG\"
echo \">dotnet --info\"
dotnet --info
echo \"$DN_INFO\"
echo \">vbc -version\"
dotnet \"$PTVBC\" -version
"

DN_INFO="
.NET SDK: 9.0.316
ASP.NET Core Runtime: 9.0.18
Visual Studio support: Visual Studio 2026 (v17.14)
Included in: Visual Studio 17.14.36
Included runtimes: .NET Runtime 9.0.18, ASP.NET Core Runtime 9.0.18, .NET Desktop Runtime 9.0.18
Language support: C# 13.0, F# 9.0, Visual Basic 17.13
more info: https://dotnet.microsoft.com/en-us/download/dotnet/9.0
"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">dotnet --info\"
echo \"$DN_INFO\"
"

CRLC="
rm -rf \"$PTTFNXD/obj\"
rm -rf \"$PTTFNXD/output\"
cp -f \"$PTFNX\" \"$PTTFNXD/Main.vb\"
cd \"$PTTFNXD\"
dotnet build \"Main.vbproj\" -c Release --verbosity quiet
cd \"$PTTFNXD/output/net9.0\"
./Main
cd \"$RD\"
rm -rf \"$PTTFNXD/output\"
rm -rf \"$PTTFNXD/obj\"
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
