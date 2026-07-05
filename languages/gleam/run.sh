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

PTTFNXD="$RD/runtimes/$LID"
TFN="main"
PTTFNX="$PTTFNXD/$TFN/src/$TFN.$X"

if [ "$IS_RUNTIME_INSTALLED" != "TRUE" ]; then
    CIR="
        cd $PTTFNXD
        gleam new $TFN
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

mkdir -p "$PTTFNXD"
sudo cp -f "$PTFNX" "$PTTFNX"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">gleam --version\"
gleam --version
echo \">erl -noshell -eval 'io:format(\\\"~s~n\\\", [erlang:system_info(system_version)]), halt().'\"
erl -noshell -eval 'io:format(\"~s~n\", [erlang:system_info(system_version)]), halt().'
echo \">cat /usr/local/lib/erlang/releases/29/OTP_VERSION\"
cat /usr/local/lib/erlang/releases/29/OTP_VERSION
"

CRLC="
cd \"$PTTFNXD/$TFN\"
gleam run
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
