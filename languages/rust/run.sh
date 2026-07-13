#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

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
