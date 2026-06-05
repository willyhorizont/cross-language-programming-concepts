#!/bin/bash

if [ -z "$1" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-extension>"
    exit 1
fi

PATH_TO_FILE_NAME_WITH_EXTENSION="$1"
PATH_TO_FILE_NAME_WITH_EXTENSION_DIR="$(dirname "$PATH_TO_FILE_NAME_WITH_EXTENSION")"
FILE_NAME_WITH_EXTENSION="$(basename "$PATH_TO_FILE_NAME_WITH_EXTENSION")"
FILE_NAME_WITHOUT_EXTENSION="${FILE_NAME_WITH_EXTENSION%.*}"
FILE_EXTENSION="${FILE_NAME_WITH_EXTENSION##*.}"

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
LANGUAGE_NAME="$(basename "$SCRIPT_DIR")"
ROOT_DIR="$(realpath "$SCRIPT_DIR/../..")"

LANGUAGE_ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$LANGUAGE_ENV_FILE" ]; then
    source "$LANGUAGE_ENV_FILE"
fi

"$ROOT_DIR/utils.sh" "setup_language_specific_vscode_extensions" "$LANGUAGE_NAME" 2>/dev/null

IMAGE=$("$ROOT_DIR/utils.sh" "get_docker_image" "$LANGUAGE_NAME" 2>/dev/null)

SEPARATOR=$("$ROOT_DIR/utils.sh" "print_separator")

PATH_TO_PACKAGE_MANAGER="$ROOT_DIR/composer"
PATH_TO_PACKAGE_MANAGER_SETUP="$ROOT_DIR/composer-setup.php"

COMMAND_CHECK_PACKAGE_MANAGER_VERSION="
echo \">composer --version\"
\"$PATH_TO_PACKAGE_MANAGER\" --version
"

COMMAND_PRINT_VERSION="
if [ -f \"$PATH_TO_PACKAGE_MANAGER\" ]; then
    $COMMAND_CHECK_PACKAGE_MANAGER_VERSION
fi
echo \">docker images\"
echo \"$IMAGE\"
echo \">php --version\"
php --version
"

COMMAND_RUN_LANGUAGE_CODE="
php \"$FILE_NAME_WITH_EXTENSION\"
"

COMMAND_INSTALL_PACKAGE_MANAGER="
if [ ! -f \"$PATH_TO_PACKAGE_MANAGER\" ]; then
    cd \"$PATH_TO_FILE_NAME_WITH_EXTENSION_DIR\"

    php -r \"copy('https://getcomposer.org/installer', '$PATH_TO_PACKAGE_MANAGER_SETUP');\"

    php -r \"if (hash_file('sha384', '$PATH_TO_PACKAGE_MANAGER_SETUP') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('$PATH_TO_PACKAGE_MANAGER_SETUP'); exit(1); }\"

    php \"$PATH_TO_PACKAGE_MANAGER_SETUP\" --version=2.10.0 --install-dir=\"$ROOT_DIR\" --filename=composer

    php -r \"unlink('$PATH_TO_PACKAGE_MANAGER_SETUP');\"

    cd \"$ROOT_DIR\"
fi
"

docker run -i --rm \
    -v "$ROOT_DIR:$ROOT_DIR" \
    "$IMAGE" \
    bash -c "
        $COMMAND_INSTALL_PACKAGE_MANAGER

        $COMMAND_PRINT_VERSION

        echo \"$SEPARATOR\"

        cd \"$PATH_TO_FILE_NAME_WITH_EXTENSION_DIR\"

        $COMMAND_RUN_LANGUAGE_CODE

        cd \"$ROOT_DIR\"
    "
