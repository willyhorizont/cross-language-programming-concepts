#!/bin/bash

if [ -z "$1" ]; then
    echo "usage:"
    echo "run.sh <path-to-filename-with-extension>"
    exit 1
fi

PTFNX="$1"
PTFNXD="$(dirname "$PTFNX")"
FNX="$(basename "$PTFNX")"
FN="${FNX%.*}"
X="${FNX##*.}"

SD="$(dirname "$(realpath "$0")")"
LID="$(basename "$SD")"
RD="$(realpath "$SD/../..")"

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

"$RD/utils.sh" "setup_language_specific_vscode_extensions" "$LID" 2>/dev/null

IMG=$("$RD/utils.sh" "get_docker_image" "$LID" 2>/dev/null)

L=$("$RD/utils.sh" "print_separator")

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">kotlinc -version\"
kotlinc -version
echo \">kotlin -version\"
kotlin -version
"

COMMAND_RUN_LANGUAGE_CODE_VERSION_ONE="kotlin"
COMMAND_RUN_LANGUAGE_CODE_VERSION_TWO="java -jar"
CRLC="
cd \"$PTFNXD\"
kotlinc \"$FNX\" -include-runtime -d \"$FN.jar\"
\"$COMMAND_RUN_LANGUAGE_CODE_VERSION_ONE\" \"$FN.jar\"
"

docker run -i --rm \
    --entrypoint bash \
    -v "$RD:$RD" \
    "$IMG" \
    -c "
        $CPV

        echo \"$L\"

        $CRLC
    "

rm -f "$PTFNXD/$FN.jar"
