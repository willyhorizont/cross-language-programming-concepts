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

LEV="$RD/.env.$LID"

if [ -f "$LEV" ]; then
    source "$LEV"
fi

IMG=$("$RD/tools/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/tools/utils.sh" --print-sep)

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
groovy --classpath \"$RD\" \"$FNX\"
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
