#!/bin/bash

C="${1:-$0}"
shift

SD="$(dirname "$(realpath "$C")")"

LID="$(basename "$SD")"
if [ -z "$1" ]; then
    echo "usage:"
    echo "\"$SD/run.sh\" path/to/*.$LID"
    exit 1
fi

PTFNX="$1"
PTFNXD="$(dirname "$PTFNX")"
FNX="$(basename "$PTFNX")"
FN="${FNX%.*}"
FX="${FNX##*.}"

RD="$(realpath "$SD/../..")"
RN="$(basename "$RD")"

PTTFNXD="$RD/runtimes/$LID"

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

IMG=$("$RD/tools/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/tools/utils.sh" --print-sep)

PTDCNTFNX="$RD/active-docker-container.txt"
