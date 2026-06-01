#!/bin/bash

if [ -z "$1" -o -z "$2" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-ext> <language>"
    exit 0
fi

PATH_TO_FILE_NAME_WITH_EXTENSION="$1"
LANGUAGE_NAME="$2"
FILE_NAME_WITH_EXTENSION=$(basename "$PATH_TO_FILE_NAME_WITH_EXTENSION")
FILE_NAME_WITHOUT_EXTENSION="${FILE_NAME_WITH_EXTENSION%.*}"
FILE_EXTENSION="${FILE_NAME_WITH_EXTENSION##*.}"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

PATH_TO_TEMP_FILE_WITH_EXTENSION="$ROOT_DIR/languages/$LANGUAGE_NAME/temp.$FILE_EXTENSION"
cp -f "$PATH_TO_FILE_NAME_WITH_EXTENSION" "$PATH_TO_TEMP_FILE_WITH_EXTENSION"

LANGUAGE_ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$LANGUAGE_ENV_FILE" ]; then
    source "$LANGUAGE_ENV_FILE"
fi

"$ROOT_DIR/utils.sh" "setup_language_specific_vscode_extensions" "$LANGUAGE_NAME" 2>/dev/null

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

scala-cli temp.$FILE_EXTENSION
rm -rf temp.$FILE_EXTENSION
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
