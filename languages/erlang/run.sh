#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/erlang/willyhorizont/runtime/xl.erl"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$FX"
    exit 1
fi

TFN="main"
PTTFNX="$RD/runtimes/erlang/main.erl"

mkdir -p "$PTTFNXD"

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">erl -noshell -eval 'io:format(\\\"~s~n\\\", [erlang:system_info(system_version)]), halt().'\"
erl -noshell -eval 'io:format(\"~s~n\", [erlang:system_info(system_version)]), halt().'
echo \">cat /usr/local/lib/erlang/releases/29/OTP_VERSION\"
cat /usr/local/lib/erlang/releases/29/OTP_VERSION
"

CRLC="
rm -f $TFN
cp -f \"$PTFNX\" \"$PTTFNX\"
cd $PTTFNXD
erlc $TFN.$FX
erl -noshell -pa \"$PTTFNXD\" -s $TFN start -s init stop
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

rm -f "$PTTFNXD/$TFN.beam"
rm -f "$PTTFNXD/xl.beam"
cd "$PTTFNXD" && rm -f *.dump
