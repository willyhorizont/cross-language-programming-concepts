#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/rust/src/willyhorizont/runtime/runtime.rs"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTFFNX=(
    "$RD/runtimes/rust/src/willyhorizont/runtime/xl.rs"
    "$RD/runtimes/rust/src/willyhorizont/runtime/mod.rs"
    "$RD/runtimes/rust/src/willyhorizont/mod.rs"
    "$RD/runtimes/rust/src/main.rs"
)
PTFNXA="$(realpath "$1" 2>/dev/null)"
if [[ " ${PTFFNX[*]} " == *" $PTFNXA "* ]]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

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
