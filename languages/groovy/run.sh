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

LEV="$RD/.env.$LID"

if [ -f "$LEV" ]; then
    source "$LEV"
fi

# "$RD/utils.sh" --setup-lang-specific-vscode-extensions $LID 2>/dev/null
code --install-extension "$RD/language-specific-extensions-installer.vsix" &> /dev/null

IMG=$("$RD/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/utils.sh" --print-sep)

if [ "$IS_INIT" != "TRUE" ]; then
    echo "IS_INIT=\"TRUE\"" > "$LEV"
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">groovy -version\"
groovy -version
echo \">groovy --version\"
groovy --version
"

CRLC="
cd \"$PTFNXD\"
groovy -cp \"$RD\" \"$FNX\"
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
