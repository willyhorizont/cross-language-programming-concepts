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

IMG=$("$RD/tools/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/tools/utils.sh" --print-sep)

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">rustc --version\"
rustc --version
echo \">cargo --version\"
cargo --version
"

CRLC="
rm -rf \"$RD/runtimes/rust/target\"
cp -f \"$PTFNX\" \"$RD/runtimes/rust/src/main.rs\"
cd \"$RD/runtimes/rust\"
cargo run
rm -rf \"$RD/runtimes/rust/target\"
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
