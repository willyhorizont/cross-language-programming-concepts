#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
PTEF="$RD/.env"
[ -f $PTEF ] && source $PTEF

print_separator() {
    printf '%*s\n' "$(tput cols)" '' | tr ' ' '-'
}

get_docker_image() {
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

case "$1" in
    --print-sep)
        print_separator
        ;;
    --get-docker-image)
        get_docker_image "$2"
        ;;
    *)
        echo "Usage: $0 {--get-docker-image} {--print-sep}"
        exit 1
        ;;
esac
