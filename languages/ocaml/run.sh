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
FX="${FNX##*.}"

RD="$(realpath "$SD/../..")"
RN="$(basename "$RD")"

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

IMG=$("$RD/tools/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/tools/utils.sh" --print-sep)

PTTFNXD="$RD/runtimes/$LID"
TFN="main"
PTTFNX="$PTTFNXD/$TFN.$FX"

mkdir -p "$PTTFNXD"
cp -f "$PTFNX" "$PTTFNX"

CPV="
echo \">docker images\"
echo \"$IMG\"
eval \$(opam env)
echo \">ocamlc --version\"
ocamlc --version
"

PTRFNX="$PTTFNXD/willyhorizont/runtime/runtime.ml"
PTRFNXD="$(dirname "$PTRFNX")"
RFNX="$(basename "$PTRFNX")"
RFN="${RFNX%.*}"
RX="${RFNX##*.}"

CRLC="
eval \$(opam env)
cd \"$PTTFNXD\"
rm -f \"$PTTFNXD/$TFN\"
rm -f \"$PTTFNXD\"/*.cmi
rm -f \"$PTTFNXD\"/*.cmo
rm -f \"$PTTFNXD\"/*.cmx
rm -f \"$PTRFNXD\"/*.o
rm -f \"$PTRFNXD\"/*.cmi
rm -f \"$PTRFNXD\"/*.cmo
rm -f \"$PTRFNXD\"/*.cmx
rm -f \"$PTRFNXD\"/*.cmx
ocamlc -c -for-pack Willyhorizont \"$PTRFNX\"
ocamlc -pack -o willyhorizont.cmo \"$PTRFNXD/$RFN.cmo\"
ocamlc -c \"$PTTFNXD/$TFN.ml\"
ocamlc -o $TFN \"$PTTFNXD/willyhorizont.cmo\" \"$PTTFNXD/$TFN.cmo\"
./$TFN
rm -f \"$PTTFNXD/$TFN\"
rm -f \"$PTTFNXD\"/*.cmi
rm -f \"$PTTFNXD\"/*.cmo
rm -f \"$PTTFNXD\"/*.cmx
rm -f \"$PTRFNXD\"/*.o
rm -f \"$PTRFNXD\"/*.cmi
rm -f \"$PTRFNXD\"/*.cmo
rm -f \"$PTRFNXD\"/*.cmx
rm -f \"$PTRFNXD\"/*.cmx
cd \"$RD\"
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
