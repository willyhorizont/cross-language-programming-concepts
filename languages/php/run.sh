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

# "$RD/utils.sh" --setup-lang-specific-vscode-extensions $LID 2>/dev/null
code --install-extension "$RD/language-specific-extensions-installer.vsix" &> /dev/null

IMG=$("$RD/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/utils.sh" --print-sep)

PTPM="$RD/composer"
PTPMS="$RD/composer-setup.php"

CCPMV="
echo \">composer --version\"
\"$PTPM\" --version
"

CPV="
if [ -f \"$PTPM\" ]; then
    $CCPMV
fi
echo \">docker images\"
echo \"$IMG\"
echo \">php --version\"
php --version
"

CRLC="
php \"$PTFNX\"
"

CIPM="
if [ ! -f \"$PTPM\" ]; then
    cd \"$PTFNXD\"

    php -r \"copy('https://getcomposer.org/installer', '$PTPMS');\"

    php -r \"if (hash_file('sha384', '$PTPMS') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('$PTPMS'); exit(1); }\"

    php \"$PTPMS\" --version=2.10.0 --install-dir=\"$RD\" --filename=composer

    php -r \"unlink('$PTPMS');\"
fi
"

docker run -i --rm \
    -v "$RD:$RD" \
    "$IMG" \
    bash -c "
        $CIPM

        $CPV

        echo \"$L\"

        $CRLC
    "
