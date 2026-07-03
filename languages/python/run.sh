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

RN="$(basename "$RD")"

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
echo \">python --version\"
python --version
echo \">pip --version\"
pip --version
"

CRLC="
cd \"$PTFNXD\"
python \"$FNX\"
"

if [[ "$RN" = "cross-language-programming-concepts" && "$FNX" != "generate-readme.py" ]]; then
    touch "$RD/languages/$LID/__init__.py"
    touch "$RD/languages/__init__.py"
    touch "$RD/runtimes/__init__.py"
    touch "$RD/runtimes/$LID/__init__.py"
    touch "$RD/runtimes/$LID/willyhorizont/__init__.py"
    CRLC="
            cd \"$RD\"
            python -m languages.python.$FN
        "
fi

docker run -i --rm \
    --entrypoint bash \
    -v "$RD:$RD" \
    "$IMG" \
    -c "
        $CPV

        echo \"$L\"

        $CRLC
    "

if [[ "$RN" = "cross-language-programming-concepts" && "$FNX" != "generate-readme.py" ]]; then
    sudo rm -f "$RD/languages/$LID/__init__.py"
    sudo rm -f "$RD/languages/__init__.py"
    sudo rm -f "$RD/runtimes/__init__.py"
    sudo rm -f "$RD/runtimes/$LID/__init__.py"
    sudo rm -f "$RD/runtimes/$LID/willyhorizont/__init__.py"
    sudo rm -rf "$RD/languages/$LID/__pycache__"
    sudo rm -rf "$RD/languages/__pycache__"
    sudo rm -rf "$RD/runtimes/__pycache__"
    sudo rm -rf "$RD/runtimes/$LID/__pycache__"
    sudo rm -rf "$RD/runtimes/$LID/willyhorizont/__pycache__"
fi
