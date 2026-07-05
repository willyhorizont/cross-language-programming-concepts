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

install_auto_install_vscode_extensions_for_opened_file_vscode_extension() {
    local og="willyhorizont"
    local rn="auto-install-vscode-extensions-for-opened-file"
    local fn="$og.$rn"
    if ! code --list-extensions 2>/dev/null | grep -i -q -x -F "$fn"; then
        echo "VSCode extension $fn not installed. Installing..."
        local burl_gh="https://github.com"
        local fnx="$fn.vsix"
        curl -L -o "$fnx" "$burl_gh/$og/$rn/releases/latest/download/$fnx"
        code --install-extension "$fnx"
        rm "$fnx"
    else
        echo "VSCode extension $fn is already installed."
    fi
}

case "$1" in
    --print-sep)
        print_separator
        ;;
    --get-docker-image)
        get_docker_image "$2"
        ;;
    --install-auto-install-vscode-extensions-for-opened-file-vscode-extension)
        install_auto_install_vscode_extensions_for_opened_file_vscode_extension
        ;;
    *)
        echo "Usage: $0 {--get-docker-image} {--print-sep}"
        exit 1
        ;;
esac
