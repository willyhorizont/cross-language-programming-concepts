#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LANGUAGE_NAME=$(basename "$SCRIPT_DIR")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

IMAGE="node:26.1.0"

if [ "$IS_RUNTIME_COMPILED" != "TRUE" ]; then
    COMMAND_INSTALL_NPM="npm install -g npm@11.13.0 --no-fund --no-audit --silent"
    COMMAND_INSTALL_RUNTIME="npm install github:willyhorizont/willyhorizont.github.io#1.0.0 --no-fund --no-audit --silent"
    echo ">$COMMAND_INSTALL_NPM"
    echo ">$COMMAND_INSTALL_RUNTIME"

    COMMAND_POST_INSTALLATION="
    rm -rf /workspace/node_modules
    rm -rf /workspace/package.json
    rm -rf /workspace/package-lock.json
    $COMMAND_INSTALL_NPM
    $COMMAND_INSTALL_RUNTIME
    "

    docker run -it --rm \
        -v "$ROOT_DIR":/workspace \
        -w /workspace \
        "$IMAGE" \
        bash -c "$COMMAND_POST_INSTALLATION"
    echo 'IS_RUNTIME_COMPILED="TRUE"' > "$ENV_FILE"
fi

COMMAND_CHECK_LANGUAGE_VERSION="
echo \">docker images\"
echo \"$IMAGE\"
echo \">node --version\"
node --version
echo \">npm --version\"
npm --version
"

COMMAND_RUN_LANGUAGE_CODE="
cd /workspace/languages/$LANGUAGE_NAME
node $FILE_NAME_WITH_EXTENSION
cd /workspace
"

docker run -it --rm \
    --entrypoint bash \
    -v "$ROOT_DIR":/workspace \
    -w /workspace \
    "$IMAGE" \
    -c "
        $COMMAND_CHECK_LANGUAGE_VERSION

        \"/workspace/utils.sh\" \"print_separator\"

        $COMMAND_RUN_LANGUAGE_CODE
    "