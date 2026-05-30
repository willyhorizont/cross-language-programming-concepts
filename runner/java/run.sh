#!/bin/bash

FILE_NAME_WITH_EXTENSION="$1"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LANGUAGE_NAME=$(basename "$SCRIPT_DIR")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

ENV_FILE="$ROOT_DIR/.env.$LANGUAGE_NAME"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

if [ "$IS_RUNTIME_INSTALLED" != "TRUE" ]; then
    rm -rf "$ROOT_DIR/runtimes/$LANGUAGE_NAME/willyhorizont/runtime/"*.class
    rm -rf "$ROOT_DIR/runtimes/$LANGUAGE_NAME/willyhorizont/"*.class
    rm -rf "$ROOT_DIR/runtimes/$LANGUAGE_NAME/"*.class
    find "$ROOT_DIR/runtimes/$LANGUAGE_NAME" -name "*.java" -print0 | xargs -0 javac -d "$ROOT_DIR/runtimes/$LANGUAGE_NAME"
    echo 'IS_RUNTIME_INSTALLED="TRUE"' > "$ENV_FILE"
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

cp /workspace/languages/$LANGUAGE_NAME/$FILE_NAME_WITH_EXTENSION /workspace/runtimes/$LANGUAGE_NAME/Main.java
javac -cp /workspace/runtimes/$LANGUAGE_NAME -d /workspace/runtimes/$LANGUAGE_NAME /workspace/runtimes/$LANGUAGE_NAME/Main.java
java -cp /workspace/runtimes/$LANGUAGE_NAME Main

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
