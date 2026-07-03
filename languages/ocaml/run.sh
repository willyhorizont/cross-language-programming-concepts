#!/bin/bash

if [ -z "$1" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-extension>"
    exit 1
fi

PTFNX="$1"
PTFNXD="$(dirname "$PTFNX")"
FNX="$(basename "$PTFNX")"
FN="${FNX%.*}"
X="${FNX##*.}"

SD="$(dirname "$(realpath "$0")")"
LID="$(basename "$SD")"
RD="$(realpath "$SD/../..")"

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

# "$RD/utils.sh" "setup_language_specific_vscode_extensions" "$LID" 2>/dev/null
code --install-extension "$RD/language-specific-extensions-installer.vsix"

IMG=$("$RD/utils.sh" "get_docker_image" "$LID" 2>/dev/null)

L=$("$RD/utils.sh" "print_separator")

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
