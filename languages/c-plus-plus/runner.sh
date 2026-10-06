#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

if [[ ".$FX" != "$XPECT_FX" ]]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTRFNX="$RD/runtimes/c-plus-plus/willyhorizont/runtime/xl.hpp"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \"docker images\"
echo \"$IMG\"
echo \"g++ -std=c++23 --version\"
g++ -std=c++23 --version
echo \"g++ -std=c++23 -dM -E -x c++ /dev/null | grep \"__cplusplus\"\"
g++ -std=c++23 -dM -E -x c++ /dev/null | grep \"__cplusplus\"
"

CCRLC="
cd \"$PTFNXD\"
g++ -std=c++23 \"$FNX\" -o \"$FN\"
./$FN
rm -f \"$PTFNXD/$FN\"
"

docker run -i --rm \
    --entrypoint bash \
    -v "$HOME:$HOME" \
    -v "$PWD:$PWD" \
    -v "$RD:$RD" \
    -v "$SD:$SD" \
    "$IMG" \
    -c "
        $CPV

        echo \"$CCRLC\"

        echo \"$L\"

        $CCRLC
    "

sudo -p "$L
Enter password to stop docker container: " systemctl disable --now docker.service 2>/dev/null
sudo systemctl disable --now containerd.service
