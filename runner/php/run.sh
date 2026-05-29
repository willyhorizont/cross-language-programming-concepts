#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LANGUAGE_NAME=$(basename "$SCRIPT_DIR")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

IMAGE="php:8.5.6-cli"

COMMAND_CHECK_LANGUAGE_VERSION="
echo \">docker images\"
echo \"$IMAGE\"
echo \">php --version\"
php --version
"
COMMAND_RUN_LANGUAGE_CODE="
cd /workspace/languages/$LANGUAGE_NAME
php $FILE_NAME_WITH_EXTENSION
cd /workspace
"

COMMAND_CHECK_PACKAGE_MANAGER_VERSION="
echo \">composer --version\"
/workspace/composer --version
"

docker run -it --rm \
    -v "$ROOT_DIR":/workspace \
    -w /workspace \
    "$IMAGE" \
    bash -c "
        $COMMAND_CHECK_LANGUAGE_VERSION

        if [ ! -f /workspace/composer ]; then
            php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\"

            php -r \"if (hash_file('sha384', 'composer-setup.php') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }\"

            php composer-setup.php --version=2.10.0 --install-dir=/workspace --filename=composer

            php -r \"unlink('composer-setup.php');\"

        fi

        if [ -f /workspace/composer ]; then
            $COMMAND_CHECK_PACKAGE_MANAGER_VERSION
        fi

        \"/workspace/utils.sh\" \"print_separator\"

        $COMMAND_RUN_LANGUAGE_CODE
    "
