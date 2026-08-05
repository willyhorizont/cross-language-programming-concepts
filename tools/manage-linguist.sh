#!/bin/bash

set -xe

rm -f linguist-languages.yml
rm -f linguist-languages.json

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

curl -L "$SRC_URL" -o "linguist-languages.yml"

python3 -c "import sys, yaml, json; print(json.dumps(yaml.safe_load(open('linguist-languages.yml')), indent=4))" > linguist-languages.json

mkdir -p output
sudo chown -R $(whoami):$(whoami) output

. "$HOME/.nvm/nvm.sh"
node manage-linguist.js
