#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/php/willyhorizont/runtime/xl.php"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$FX"
    exit 1
fi

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
    php -r \"copy('https://getcomposer.org/installer', '$PTPMS');\"

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
