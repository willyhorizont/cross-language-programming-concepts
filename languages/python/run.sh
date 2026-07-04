#!/bin/bash
export PYTHONDONTWRITEBYTECODE=1

SD="$(dirname "$(realpath "$0")")"
LID="$(basename "$SD")"
if [ -z "$1" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$LID"
    exit 1
fi

PTFNX="$1"
PTFNXD="$(dirname "$PTFNX")"
FNX="$(basename "$PTFNX")"
FN="${FNX%.*}"
X="${FNX##*.}"

RD="$(realpath "$SD/../..")"
RN="$(basename "$RD")"

PTRFNX="$RD/runtimes/python/willyhorizont/runtime.py"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$LID"
    exit 1
fi

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

# "$RD/utils.sh" --setup-lang-specific-vscode-extensions $LID 2>/dev/null
code --install-extension "$RD/language-specific-extensions-installer.vsix" &> /dev/null

IMG=$("$RD/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/utils.sh" --print-sep)

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


# sudo chown -R $USER: "$RD"
# sudo rm -f "$RD/languages/$LID/__init__.py"
# sudo rm -f "$RD/languages/__init__.py"
# sudo rm -f "$RD/runtimes/__init__.py"
# sudo rm -f "$RD/runtimes/$LID/__init__.py"
# sudo rm -f "$RD/runtimes/$LID/willyhorizont/__init__.py"
# sudo rm -rf "$RD/languages/$LID/__pycache__"
# sudo rm -rf "$RD/languages/__pycache__"
# sudo rm -rf "$RD/runtimes/__pycache__"
# sudo rm -rf "$RD/runtimes/$LID/__pycache__"
# sudo rm -rf "$RD/runtimes/$LID/willyhorizont/__pycache__"
rm -f "$RD/languages/$LID/__init__.py"
rm -f "$RD/languages/__init__.py"
rm -f "$RD/runtimes/__init__.py"
rm -f "$RD/runtimes/$LID/__init__.py"
rm -f "$RD/runtimes/$LID/willyhorizont/__init__.py"

python3 -m compileall -q --purge "$RD" 2>/dev/null

find "$RD" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null

# echo "sudo chown -R \$USER: \"$RD\""
# echo "sudo rm -f \"$RD/languages/$LID/__init__.py\""
# echo "sudo rm -f \"$RD/languages/__init__.py\""
# echo "sudo rm -f \"$RD/runtimes/__init__.py\""
# echo "sudo rm -f \"$RD/runtimes/$LID/__init__.py\""
# echo "sudo rm -f \"$RD/runtimes/$LID/willyhorizont/__init__.py\""
# echo "sudo rm -rf \"$RD/languages/$LID/__pycache__\""
# echo "sudo rm -rf \"$RD/languages/__pycache__\""
# echo "sudo rm -rf \"$RD/runtimes/__pycache__\""
# echo "sudo rm -rf \"$RD/runtimes/$LID/__pycache__\""
# echo "sudo rm -rf \"$RD/runtimes/$LID/willyhorizont/__pycache__\""
