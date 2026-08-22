#!/bin/bash

PTFNX="$1"
if [[ "$PTFNX" == ./* ]]; then
    PTFNX="$RD/${PTFNX#./}"
fi
PTFNXD="$(dirname "$PTFNX")"
FNX="$(basename "$PTFNX")"
FN="${FNX%.*}"
FX="${FNX##*.}"

if [[ ".$FX" == ".sh" ]]; then
    bash "$PTFNX"
    exit 0
fi

LID="$(basename "$PTFNXD")"
RD=$(dirname "$(dirname "$PTFNXD")")

CODE_RUNNER="$RD/languages/$LID/runner.sh"
cd "$RD"
PROMPT_DIR="${RD//"$HOME"/~}"
PROMPT_STR="${USER}@$(hostname):${PROMPT_DIR}\$"

if [ -f "$CODE_RUNNER" ]; then
    echo -e "\e[1;32m${PROMPT_STR}\e[0m \"$CODE_RUNNER\" \"$PTFNXD\""
    bash "$CODE_RUNNER" "$PTFNX"
else
    fastfetch
    echo "invalid code-runner"
    exit 1
fi
