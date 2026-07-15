#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

IS_ANY_MATLAB_COMMENT=false
if grep -q -E "%\{|%\}" "$PTFNX"; then
    IS_ANY_MATLAB_COMMENT=true
else
    IS_ANY_MATLAB_COMMENT=false
fi

IS_ANY_OBJC_KEYWORD=false
if grep -q -E "#import|<Foundation/Foundation\.h>|@class|@interface|@property|@end|@implementation" "$PTFNX"; then
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

IS_ANY_OBJC_METHOD_CALL=false
if grep -q -E "\[[a-zA-Z_]" "$PTFNX"; then
    IS_ANY_OBJC_METHOD_CALL=true
else
    IS_ANY_OBJC_METHOD_CALL=false
fi

if ! { [ "$IS_ANY_MATLAB_COMMENT" = false ] && [ "$IS_ANY_OBJC_KEYWORD" = true ] && ( [ "$IS_ANY_OBJC_NS_PREFIX" = true ] || [ "$IS_ANY_OBJC_METHOD_CALL" = true ] ); }; then
    if [ "$IS_ANY_MATLAB_COMMENT" = true ]; then
        bash "/home/willy/Documents/Codes/cross-language-programming-concepts/languages/matlab/runner.sh" "$1"
        exit 0
    fi
    echo "C runtime is not supported"
    exit 1
fi

PTRFNX="$RD/runtimes/objective-c/willyhorizont/runtime/xl.h"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
"

CRLC="
cd \"$PTFNXD\"
objc $FNX -o $FN
./$FN
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

rm -f "$PTFNXD/$FN"