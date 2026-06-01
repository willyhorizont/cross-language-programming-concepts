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

if [ "$IS_RUNTIME_INSTALLED" != "TRUE" ]; then
    rm -rf "$ROOT_DIR/runtimes/$LANGUAGE_NAME/willyhorizont/runtime/"*.class
    rm -rf "$ROOT_DIR/runtimes/$LANGUAGE_NAME/willyhorizont/"*.class
    rm -rf "$ROOT_DIR/runtimes/$LANGUAGE_NAME/"*.class
    find "$ROOT_DIR/runtimes/$LANGUAGE_NAME" -name "*.java" -print0 | xargs -0 javac -d "$ROOT_DIR/runtimes/$LANGUAGE_NAME"
    echo 'IS_RUNTIME_INSTALLED="TRUE"' > "$LANGUAGE_ENV_FILE"
fi

IMAGE="eclipse-temurin:26.0.1_8-jdk"

COMMAND_CHECK_LANGUAGE_VERSION="
echo \">docker images\"
echo \"$IMAGE\"
echo \">java -version\"
java -version
echo \">javac -version\"
javac -version
"

COMMAND_RUN_LANGUAGE_CODE="
rm -f /workspace/runtimes/$LANGUAGE_NAME/Main.java
rm -f /workspace/runtimes/$LANGUAGE_NAME/Main.class

cp -f /workspace/languages/$LANGUAGE_NAME/temp.java /workspace/runtimes/$LANGUAGE_NAME/Main.java
javac -cp /workspace/runtimes/$LANGUAGE_NAME -d /workspace/runtimes/$LANGUAGE_NAME /workspace/runtimes/$LANGUAGE_NAME/Main.java
java -cp /workspace/runtimes/$LANGUAGE_NAME Main

rm -f /workspace/languages/$LANGUAGE_NAME/temp.java

rm -f /workspace/runtimes/$LANGUAGE_NAME/Main.java
rm -f /workspace/runtimes/$LANGUAGE_NAME/Main.class
rm -f /workspace/runtimes/$LANGUAGE_NAME/*.class
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
