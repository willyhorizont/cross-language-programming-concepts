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

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">typst --version\"
typst --version
echo \">typst -V\"
typst -V
"

PTOFNXD="$RD/runtimes/typst/willyhorizont/output/$LID"
mkdir -p "$PTOFNXD"
PTOFNX="$PTOFNXD/$FN.pdf"
UN="$(whoami)"
UC="$(hostname)"
UPWD="$(pwd | sed "s|^$HOME|~|")"

CRLC="
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
