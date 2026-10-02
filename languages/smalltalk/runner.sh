#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

if [[ ".$FX" != "$XPECT_FX" ]]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTRFNX="$RD/runtimes/smalltalk/willyhorizont/runtime/xl.st"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

CPV="
echo \"docker images\"
echo \"$IMG\"
echo \"pharo /opt/pharo/Pharo.image --version\"
pharo /opt/pharo/Pharo.image --version
echo \"pharo /opt/pharo/Pharo.image printVersion\"
pharo /opt/pharo/Pharo.image printVersion
echo \"pharo /opt/pharo/Pharo.image eval \"SystemVersion current version\"\"
pharo /opt/pharo/Pharo.image eval \"SystemVersion current version\"
"

CCRLC="
pharo /opt/pharo/Pharo.image st --quit \"$PTRFNX\" \"$PTFNX\"
"

if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    docker build \
        -t "$IMG" \
        -f "$RD/docker/$LID/Dockerfile" \
        "$RD"
fi

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
Enter password to stop docker container: " systemctl stop --no-block docker.service containerd.service 2>/dev/null
