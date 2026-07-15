#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/typst/willyhorizont/runtime/xl.typ"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">typst --version\"
typst --version
echo \">typst -V\"
typst -V
"

PTOFNXD="$RD/runtimes/typst/output"
mkdir -p "$PTOFNXD"
PTOFNX="$PTOFNXD/$FN.pdf"
UN="$(whoami)"
UC="$(hostname)"
UPWD="$(pwd | sed "s|^$HOME|~|")"

CRLC="
rm -f \"$PTOFNX\"
cd \"$PTFNXD\"
typst compile --open --root \"$RD\" --input user-name=$UN --input user-computer=$UC --input user-pwd=$UPWD --input file-name-with-extension=\"$FNX\" \"$FNX\" \"$PTOFNX\"
echo \"if output not open automatically, open it here: \\\"$PTOFNX\\\"\"
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

if [ -f "$PTOFNX" ]; then
    code -r "$PTOFNX"
fi
