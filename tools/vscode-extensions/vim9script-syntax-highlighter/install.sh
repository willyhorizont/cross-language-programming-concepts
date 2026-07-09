#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/../../../")
echo "$RD"
cd "$SD"
r="https://github.com/willyhorizont/vim9script-vscode-syntax-highlighter-extension.git"
# r="https://github.com/DanBradbury/language-vim9.git"
rn="${r##*/}"
rn="${rn%.git}"
TD="$SD/repos/$rn"
rm -rf "$TD"
git clone "$r" "$TD"
cd "$RD"
TFNX="$TD/package.json"
jq '.publisher |= gsub("[^a-zA-Z0-9]"; "")' "$TFNX" > "$TFNX.tmp" && mv "$TFNX.tmp" "$TFNX"
N=$(jq -r '.name' "$TFNX")
P=$(jq -r '.publisher' "$TFNX")
V=$(jq -r '.version' "$TFNX")
rm -f "$SD/*.vsix"
\. "$HOME/.nvm/nvm.sh"
cd "$TD"
code --uninstall-extension "$P.$N"
vsce package --no-dependencies -o "$SD/$P.$N.vsix"
cd "$SD"
code --install-extension "$P.$N.vsix"
