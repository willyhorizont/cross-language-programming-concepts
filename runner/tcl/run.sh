#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LANGUAGE_NAME=$(basename "$SCRIPT_DIR")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

IMAGE="siqsuruq/tcl:9.0.3-debian"

COMMAND_CHECK_LANGUAGE_VERSION="
echo \">docker images\"
echo \"$IMAGE\"
echo \">echo \\\"puts [info patchlevel]\\\" | tclsh\"
echo \"puts [info patchlevel]\" | tclsh
"

COMMAND_RUN_LANGUAGE_CODE="
cd /workspace/languages/$LANGUAGE_NAME
tclsh $FILE_NAME_WITH_EXTENSION
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
