#!/bin/bash

if [ -z "$1" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-extension>"
    exit 1
fi

PTFNX="$1"
PTFNXD="$(dirname "$PTFNX")"
FNX="$(basename "$PTFNX")"
FN="${FNX%.*}"
X="${FNX##*.}"

SD="$(dirname "$(realpath "$0")")"
LID="$(basename "$SD")"
RD="$(realpath "$SD/../..")"

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

# "$RD/utils.sh" "setup_language_specific_vscode_extensions" "$LID" 2>/dev/null
code --install-extension "$RD/language-specific-extensions-installer.vsix"

IMG=$("$RD/utils.sh" "get_docker_image" "$LID" 2>/dev/null)

L=$("$RD/utils.sh" "print_separator")

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">nix --version\"
nix --version
echo \">nix-env --version\"
nix-env --version
echo \">nix-build --version\"
nix-build --version
echo \">nix-env --versionnix-build --version\"
nix-env --versionnix-build --version
"

CRLC="
cd \"$PTFNXD\"
nix-instantiate --eval --strict \"$FNX\"
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
