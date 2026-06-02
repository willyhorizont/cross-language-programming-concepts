#!/bin/bash

if [ -z "$1" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-extension>"
    exit 0
fi

PATH_TO_FILE_NAME_WITH_EXTENSION="$1"
PATH_TO_FILE_NAME_WITH_EXTENSION_DIR=$(dirname "$PATH_TO_FILE_NAME_WITH_EXTENSION")
FILE_NAME_WITH_EXTENSION=$(basename "$PATH_TO_FILE_NAME_WITH_EXTENSION")
FILE_NAME_WITHOUT_EXTENSION="${FILE_NAME_WITH_EXTENSION%.*}"
FILE_EXTENSION="${FILE_NAME_WITH_EXTENSION##*.}"

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

COMMAND_RUN_LANGUAGE_CODE_VERSION_ONE="kotlin"
COMMAND_RUN_LANGUAGE_CODE_VERSION_TWO="java -jar"
COMMAND_RUN_LANGUAGE_CODE="
cd $PATH_TO_FILE_NAME_WITH_EXTENSION_DIR

kotlinc $FILE_NAME_WITH_EXTENSION -include-runtime -d $FILE_NAME_WITHOUT_EXTENSION.jar
$COMMAND_RUN_LANGUAGE_CODE_VERSION_ONE $FILE_NAME_WITHOUT_EXTENSION.jar
rm -rf $FILE_NAME_WITHOUT_EXTENSION.jar

cd $ROOT_DIR
"

docker run -it --rm \
    --entrypoint bash \
    -v "$ROOT_DIR:$ROOT_DIR" \
    -w "$ROOT_DIR" \
    "$IMAGE" \
    -c "
        $COMMAND_CHECK_LANGUAGE_VERSION

        $ROOT_DIR/utils.sh print_separator

        $COMMAND_RUN_LANGUAGE_CODE
    "
