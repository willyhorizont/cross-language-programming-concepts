#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"
FILE_NAME_WITHOUT_EXTENSION="${FILE_NAME_WITH_EXTENSION%.*}"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LANGUAGE_NAME=$(basename "$SCRIPT_DIR")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

LANGUAGE_ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$LANGUAGE_ENV_FILE" ]; then
    source "$LANGUAGE_ENV_FILE"
fi

"$ROOT_DIR/utils.sh" "setup_language_specific_vscode_extensions" "$LANGUAGE_NAME" 2>/dev/null

IMAGE="danysk/kotlin:2.3.21-jdk23"

COMMAND_CHECK_LANGUAGE_VERSION="
echo \">docker images\"
echo \"$IMAGE\"
echo \">kotlinc -version\"
kotlinc -version
echo \">kotlin -version\"
kotlin -version
"

COMMAND_RUN_LANGUAGE_CODE="
kotlinc $FILE_NAME_WITHOUT_EXTENSION.kt -include-runtime -d $FILE_NAME_WITHOUT_EXTENSION.jar
kotlin $FILE_NAME_WITHOUT_EXTENSION.jar
rm -rf $FILE_NAME_WITHOUT_EXTENSION.jar
"

COMMAND_RUN_LANGUAGE_CODE_VERSION_TWO="
kotlinc $FILE_NAME_WITHOUT_EXTENSION.kt -include-runtime -d $FILE_NAME_WITHOUT_EXTENSION.jar
java -jar $FILE_NAME_WITHOUT_EXTENSION.jar
rm -rf $FILE_NAME_WITHOUT_EXTENSION.jar
"

docker run -it --rm \
    --entrypoint bash \
    -v "$ROOT_DIR":/workspace \
    -w /workspace \
    "$IMAGE" \
    -c "
        $COMMAND_CHECK_LANGUAGE_VERSION

        \"/workspace/utils.sh\" \"print_separator\"

        cd /workspace/languages/$LANGUAGE_NAME

        $COMMAND_RUN_LANGUAGE_CODE

        cd /workspace
    "
