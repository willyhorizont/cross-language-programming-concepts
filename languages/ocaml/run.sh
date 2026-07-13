#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/ocaml/willyhorizont/runtime/runtime.ml"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$LID"
    exit 1
fi

TFN="main"
PTTFNX="$PTTFNXD/$TFN.$X"

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
