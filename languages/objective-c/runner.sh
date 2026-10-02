#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

if [[ ".$FX" != "$XPECT_FX" ]]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

IS_ANY_MATLAB_KEYWORD=false
if grep -q -E "%\{|%\}|\bfunction\b|\bend\b|\bdisp\b" "$PTFNX"; then
    IS_ANY_MATLAB_KEYWORD=true
else
    IS_ANY_MATLAB_KEYWORD=false
fi
if [[ "$PTFNX" == *.h ]]; then
    IS_ANY_MATLAB_KEYWORD=false
fi

IS_ANY_C_KEYWORD=false
if grep -q -E "#include|<stdio\.h>" "$PTFNX"; then
    IS_ANY_C_KEYWORD=true
else
    IS_ANY_C_KEYWORD=false
fi

IS_ANY_OBJC_KEYWORD=false
if grep -q -E "#import|<Foundation/Foundation\.h>|@class\b|@interface\b|@property\b|@end\b|@implementation\b" "$PTFNX"; then
    IS_ANY_OBJC_KEYWORD=true
else
    IS_ANY_OBJC_KEYWORD=false
fi

IS_ANY_OBJC_NS_PREFIX=false
if grep -q -E "\bNS[A-Z]" "$PTFNX"; then
    IS_ANY_OBJC_NS_PREFIX=true
else
    IS_ANY_OBJC_NS_PREFIX=false
fi

MAYBE_OBJC=false
if [[ "$IS_ANY_OBJC_KEYWORD" == true || "$IS_ANY_OBJC_NS_PREFIX" == true  ]]; then
    MAYBE_OBJC=true
else
    MAYBE_OBJC=false
fi

if [[ "$IS_ANY_MATLAB_KEYWORD" == true && "$MAYBE_OBJC" == false ]]; then
    bash "$RD/languages/matlab-or-octave/runner.sh" "$1"
    exit 0
fi

if [[ "$IS_ANY_C_KEYWORD" == true && "$MAYBE_OBJC" == false ]]; then
    bash "$RD/languages/c/runner.sh" "$1"
    exit 0
fi

PTRFNX="$RD/runtimes/objective-c/willyhorizont/runtime/xl.h"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \"docker images\"
echo \"$IMG\"
echo \"objc --version\"
objc --version
echo \"clang-19 -fobjc-runtime=gnustep-2.0 --version\"
clang-19 -fobjc-runtime=gnustep-2.0 --version
echo \"cat /opt/gnustep/share/GNUstep/Makefiles/config.make | grep \"DEFAULT_OBJC_RUNTIME_ABI\"\"
cat /opt/gnustep/share/GNUstep/Makefiles/config.make | grep \"DEFAULT_OBJC_RUNTIME_ABI\"
"

CRLC="
cd \"$PTFNXD\"
objc $FNX -o $FN
./$FN
rm -f \"$PTFNXD/$FN\"
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    docker build \
        -t "$IMG" \
        -f "$RD/docker/$LID/Dockerfile" \
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

        echo \"$CRLC\"

        echo \"$L\"

        $CRLC
    "

sudo -p "$L
Enter password to stop docker container: " systemctl stop --no-block docker.service containerd.service 2>/dev/null
