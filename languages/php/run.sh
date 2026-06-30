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

"$RD/utils.sh" "setup_language_specific_vscode_extensions" "$LID" 2>/dev/null

IMG=$("$RD/utils.sh" "get_docker_image" "$LID" 2>/dev/null)

L=$("$RD/utils.sh" "print_separator")

PATH_TO_PACKAGE_MANAGER="$RD/composer"
PATH_TO_PACKAGE_MANAGER_SETUP="$RD/composer-setup.php"

COMMAND_CHECK_PACKAGE_MANAGER_VERSION="
echo \">composer --version\"
\"$PATH_TO_PACKAGE_MANAGER\" --version
"

CPV="
if [ -f \"$PATH_TO_PACKAGE_MANAGER\" ]; then
    $COMMAND_CHECK_PACKAGE_MANAGER_VERSION
fi
echo \">docker images\"
echo \"$IMG\"
echo \">php --version\"
php --version
"

CRLC="
cd \"$PTFNXD\"
php \"$FNX\"
"

CIPM="
if [ ! -f \"$PATH_TO_PACKAGE_MANAGER\" ]; then
    cd \"$PTFNXD\"

    php -r \"copy('https://getcomposer.org/installer', '$PATH_TO_PACKAGE_MANAGER_SETUP');\"

    php -r \"if (hash_file('sha384', '$PATH_TO_PACKAGE_MANAGER_SETUP') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('$PATH_TO_PACKAGE_MANAGER_SETUP'); exit(1); }\"

    php \"$PATH_TO_PACKAGE_MANAGER_SETUP\" --version=2.10.0 --install-dir=\"$RD\" --filename=composer

    php -r \"unlink('$PATH_TO_PACKAGE_MANAGER_SETUP');\"
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
