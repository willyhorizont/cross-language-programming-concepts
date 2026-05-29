#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LANGUAGE_NAME=$(basename "$SCRIPT_DIR")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

IMAGE="nixos/nix:2.34.7"

COMMAND_CHECK_LANGUAGE_VERSION="
echo \">docker images\"
echo \"$IMAGE\"

echo \">nix --version\"
nix --version

echo \">nix-env --version\"
nix-env --version

echo \">nix-build --version\"
nix-build --version

echo \">nix-env --versionnix-build --version\"
nix-env --versionnix-build --version
"

# echo \">nixos-version\"
# nixos-version

# echo \">nix doctor\"
# nix doctor

COMMAND_RUN_LANGUAGE_CODE="
cd /workspace/languages/$LANGUAGE_NAME
nix-instantiate --eval $FILE_NAME_WITH_EXTENSION
cd /workspace
"
# nix-build $FILE_NAME_WITH_EXTENSION
# nix-shell --run $FILE_NAME_WITH_EXTENSION
# nix run  $FILE_NAME_WITH_EXTENSION
# nix-instantiate --eval $FILE_NAME_WITH_EXTENSION
# nix-instantiate --eval --strict $FILE_NAME_WITH_EXTENSION

separator=$("$ROOT_DIR/utils.sh" "print_separator")

docker run -it --rm \
    --entrypoint bash \
    -v "$ROOT_DIR":/workspace \
    -w /workspace \
    "$IMAGE" \
    -c "
        $COMMAND_CHECK_LANGUAGE_VERSION

        echo \">nix-instantiate --help\"

        echo \"$separator\"

        $COMMAND_RUN_LANGUAGE_CODE
    "
