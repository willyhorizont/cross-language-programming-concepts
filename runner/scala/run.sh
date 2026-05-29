#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LANGUAGE_NAME=$(basename "$SCRIPT_DIR")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

DOCKERFILE_PATH="$ROOT_DIR/docker/$LANGUAGE_NAME/Dockerfile"
IMAGE=$(awk "NR==1 {sub(/^FROM[ ]{1}/,""); print}" "$DOCKERFILE_PATH" 2>/dev/null)
IMAGE="virtuslab/scala-cli:1.13.0" # scala-cli:1.13.0 == scala:3.8.3

COMMAND_CHECK_LANGUAGE_VERSION="
echo \">docker images\"
echo \"$IMAGE\"
echo \">scala-cli version\"
scala-cli version
"

COMMAND_RUN_LANGUAGE_CODE="
cd /workspace/languages/$LANGUAGE_NAME
scala-cli $FILE_NAME_WITH_EXTENSION
cd /workspace
"

docker run -it --rm \
    --entrypoint bash \
    -v scala-coursier-cache:/root/.cache/coursier \
    -v "$ROOT_DIR":/workspace \
    -w /workspace \
    "$IMAGE" \
    -c "
        $COMMAND_CHECK_LANGUAGE_VERSION

        \"/workspace/utils.sh\" \"print_separator\"

        $COMMAND_RUN_LANGUAGE_CODE
    "
