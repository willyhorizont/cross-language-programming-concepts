#!/bin/bash

set -xe

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")

rm -f "$RD/tmp/linguist-languages.yml"
rm -f "$RD/tmp/linguist-languages.json"

D1="https://"
D2="raw."
D3="githubusercontent"
D4=".com"
DOMAIN="${D1}${D2}${D3}${D4}"

P1="/github-linguist"
P2="/linguist"
P3="/main"
P4="/lib"
P5="/linguist"
P6="/languages.yml"
SUBPATH="${P1}${P2}${P3}${P4}${P5}${P6}"

SRC_URL="${DOMAIN}${SUBPATH}"

mkdir -p "$RD/tmp"

curl -L "$SRC_URL" -o "$RD/tmp/linguist-languages.yml"

if ! python3 -c "import yaml" 2>/dev/null; then
    echo "Installing python3-yaml..."
    sudo apt update && sudo apt install -y python3-yaml
fi

python3 -c "import sys, yaml, json; print(json.dumps(yaml.safe_load(open('$RD/tmp/linguist-languages.yml')), indent=4))" > "$RD/tmp/linguist-languages.json"

sudo chown -R $(whoami):$(whoami) "$RD/tmp"

LID="javascript-or-typescript"
IMG=$("$RD/tools/utils.sh" --get-docker-image $LID 2>/dev/null)

docker run -i --rm \
    --entrypoint bash \
    -v "$RD:$RD" \
    "$IMG" \
    -c "
        cd \"$RD\"
        node \"$RD/tools/manage-linguist.js\"
    "

sudo chown -R $(whoami):$(whoami) "$RD/tmp/linguist-programming-languages.json"
