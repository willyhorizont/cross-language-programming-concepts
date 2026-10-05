#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
PTEF="$RD/.env"
[ -f $PTEF ] && source $PTEF

prt_sep() {
    local cols=$(tput cols 2>/dev/null || echo 54)
    cols=$(( cols - 3 ))

    local ln
    printf -v ln "%*s" "$cols" ""
    
    printf '%s\n\033[K\n' "${ln// /-}"
}

get_docker_img() {
    if [ -z "$1" ]; then
        echo "expected <language-id>"
        exit 1
    fi
    local -r LID="${1}"
    local -r IMG=$(jq -r --arg lang "$LID" '
        .[]
        | select(.["id"] == $lang)
        | .["docker"]
        | .[-1]
        | .["docker_images"]
        | .[-1]
    ' "$RD/languages.json")
    echo "$IMG"
}

get_lang_ext() {
    if [ -z "$1" ]; then
        echo "expected <language-id>"
        exit 1
    fi
    local -r LID="${1}"
    local -r LFX=$(jq -r --arg lang "$LID" '
        .[]
        | select(.["id"] == $lang)
        | .["file_extension"]
    ' "$RD/languages.json")
    echo "$LFX"
}

case "$1" in
    --print-sep)
        prt_sep
        ;;
    --get-docker-image)
        get_docker_img "$2"
        ;;
    --get-lang-ext)
        get_lang_ext "$2"
        ;;
    *)
        echo "Usage: $0 {--get-docker-image} {--get-lang-ext} {--print-sep}"
        exit 1
        ;;
esac
