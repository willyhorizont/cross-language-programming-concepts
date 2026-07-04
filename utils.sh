#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD")
PTEF="$RD/.env"
[ -f $PTEF ] && source $PTEF

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
    ' "$SD/languages.json")
    echo "$IMG"
}

setup_language_specific_vscode_extensions() {
    if [ -z "$1" ]; then
        echo "expected <language-id>"
        exit 1
    fi
    local -r tl="${1}"
    if [ "$CAL" == "$tl" ]; then
        echo "[language-specific-extensions] vscode extensions for \"$tl\" is active"
        return 0
    fi

    if ! command -v jq &> /dev/null; then
        echo "jq not installed. installing jq..."
        sudo apt update && sudo apt install -y jq
    fi
    mapfile -t veftl < <(jq -r --arg target "$tl" '.[] | select(.["id"] == $target) | .["vscode_extensions"] | .[]' "$RD/languages.json" 2>/dev/null)

    if [ ${#veftl[@]} -eq 0 ]; then
        echo "[language-specific-extensions] vscode extensions for \"$tl\" is not available"
        return 0
    fi
    echo "[language-specific-extensions] found vscode extensions for \"$tl\""

    declare -a jinst_ext=()
    local ptvscextb="$RD/vscode-extensions-base.txt"
    mapfile -t base_extensions < $ptvscextb
    mapfile -t jinst_ext < $ptvscextb

    local ptlo_cinst_ext="$RD/vscode-extensions-current.txt"
    code --list-extensions 2>/dev/null | grep -v -E "(stdin|Usage|Options)" > "$ptlo_cinst_ext"

    for b_ext in "${base_extensions[@]}"; do
        if grep -qix "$b_ext" "$ptlo_cinst_ext"; then
            continue
        fi
        code --install-extension "$b_ext" --force
        jinst_ext+=( "$b_ext" )
    done

    for ext_ftl in "${veftl[@]}"; do
        if grep -qix "$ext_ftl" "$ptlo_cinst_ext"; then
            continue
        fi
        code --install-extension "$ext_ftl" --force
        jinst_ext+=( "$ext_ftl" )
    done

    while read -r installed_ext; do
        [ -z "$installed_ext" ] && continue

        local inst_ext_l="${installed_ext,,}"

        local sk=false

        if grep -qix "$inst_ext_l" "$ptvscextb"; then
            continue
        fi

        for ext_ftl in ${veftl}; do
            if [ "$inst_ext_l" == "${ext_ftl,,}" ]; then
                sk=true
                break
            fi
        done

        if ! $sk; then
            code --uninstall-extension "$installed_ext"
            continue
        fi
    done < $ptlo_cinst_ext

    echo "CAL=$tl" > $PTEF
    printf "%s\n" "${jinst_ext[@]}" > "$ptlo_cinst_ext"
    echo "[language-specific-extensions] vscode extensions for \"$tl\" is active"
}

print_separator() {
    printf '%*s\n' "$(tput cols)" '' | tr ' ' '-'
}

check_path() {
    declare -r p="$1"

    if [ -d "$p" ]; then
        echo "$p is DIRECTORY"
    elif [ -f "$p" ]; then
        echo "$p is FILE"
    else
        echo "$p not found"
    fi
}

case "$1" in
    --print-sep)
        print_separator
        ;;
    --check-path)
        check_path "$2"
        ;;
    --get-docker-image)
        get_docker_image "$2"
        ;;
    --setup-lang-specific-vscode-extensions)
        setup_language_specific_vscode_extensions "$2"
        ;;
    *)
        echo "Usage: $0 {--check-path} {--get-docker-image} {--setup-lang-specific-vscode-extensions} {--print-sep}"
        exit 1
        ;;
esac
