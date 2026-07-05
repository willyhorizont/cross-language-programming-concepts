#!/bin/bash

SD="$(dirname "$(realpath "$0")")"
LID="$(basename "$SD")"
if [ -z "$1" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$LID"
    exit 1
fi

PTFNX="$1"
PTFNXD="$(dirname "$PTFNX")"
FNX="$(basename "$PTFNX")"
FN="${FNX%.*}"
X="${FNX##*.}"

RD="$(realpath "$SD/../..")"
RN="$(basename "$RD")"

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

"$RD/tools/utils.sh" --install-auto-install-vscode-extensions-for-opened-file-vscode-extension 2>/dev/null

IMG=$("$RD/tools/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/tools/utils.sh" --print-sep)

PTTFNXD="$RD/runtimes/$LID/runtime"
TFN="main"
PTTFNX="$PTTFNXD/$TFN.$X"

mkdir -p "$PTTFNXD"
cp -f "$PTFNX" "$PTTFNX"

if [ "$IS_RUNTIME_INSTALLED" != "TRUE" ]; then
    CIR="
        eval \$(opam env)
        ocamlopt -c \"$PTTFNXD/willyhorizont.ml\"
    "
    docker run -i --rm \
        --entrypoint bash \
        -v "$RD:$RD" \
        "$IMG" \
        -c "
            $CIR
        "
    echo "IS_RUNTIME_INSTALLED=\"TRUE\"" > "$LEF"
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
eval \$(opam env)
echo \">ocamlc --version\"
ocamlc --version
"

CRLC="
ocamlopt -I \"$PTTFNXD\" -o \"$PTTFNXD/$TFN\" \"$PTTFNXD/willyhorizont.cmx\" \"$PTTFNXD/$TFN.$X\"
cd \"$PTTFNXD\"
./$TFN
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

rm -f "$PTTFNXD/$TFN.cmi"
rm -f "$PTTFNXD/$TFN.cmx"
rm -f "$PTTFNXD/$TFN.ml"
rm -f "$PTTFNXD/$TFN.o"
rm -f "$PTTFNXD/$TFN"
