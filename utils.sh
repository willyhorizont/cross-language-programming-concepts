#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR")
PATH_TO_DOT_ENV_FILE="$ROOT_DIR/.env"
[ -f $PATH_TO_DOT_ENV_FILE ] && source $PATH_TO_DOT_ENV_FILE

get_docker_image() {
    if [ -z "$1" ]; then
        echo "expected <language-id>"
        exit 1
    fi
    local -r language_id="${1}"
    local -r docker_image=$(jq -r --arg lang "$language_id" '
        .[]

        | select(.[0] == $lang)
        | .[7][-1]
        | .[-1]
        | .[-1]
    ' "$SCRIPT_DIR/languages.json")
    echo "$docker_image"
}

setup_language_specific_vscode_extensions() {
    if [ -z "$1" ]; then
        echo "expected <language-id>"
        exit 1
    fi
    local -r target_lang="${1}"
    if [ "$CURRENT_ACTIVE_LANGUAGE" == "$target_lang" ]; then
        echo "[language-specific-extensions] vscode extensions for \"$target_lang\" is active"
        return 0
    fi

    if ! command -v jq &> /dev/null; then
        echo "jq not installed. installing jq..."
        sudo apt update && sudo apt install -y jq
    fi
    mapfile -t vscode_extensions_for_target_lang < <(jq -r --arg target "$target_lang" '.[] | select(.[0] == $target) | .[5] | .[]' "$ROOT_DIR/languages.json" 2>/dev/null)

    if [ ${#vscode_extensions_for_target_lang[@]} -eq 0 ]; then
        echo "[language-specific-extensions] vscode extensions for \"$target_lang\" is not available"
        return 0
    fi
    echo "[language-specific-extensions] found vscode extensions for \"$target_lang\""

    declare -a just_installed_extensions=()
    local path_to_vscode_extensions_base="$ROOT_DIR/vscode-extensions-base.txt"
    mapfile -t base_extensions < $path_to_vscode_extensions_base
    mapfile -t just_installed_extensions < $path_to_vscode_extensions_base

    local path_to_list_of_current_installed_extensions="$ROOT_DIR/vscode-extensions-current.txt"
    code --list-extensions 2>/dev/null | grep -v -E "(stdin|Usage|Options)" > "$path_to_list_of_current_installed_extensions"

    for base_ext in "${base_extensions[@]}"; do
        if grep -qix "$base_ext" "$path_to_list_of_current_installed_extensions"; then
            continue
        fi
        code --install-extension "$base_ext" --force
        just_installed_extensions+=( "$base_ext" )
    done

    for ext_for_target_lang in "${vscode_extensions_for_target_lang[@]}"; do
        if grep -qix "$ext_for_target_lang" "$path_to_list_of_current_installed_extensions"; then
            continue
        fi
        code --install-extension "$ext_for_target_lang" --force
        just_installed_extensions+=( "$ext_for_target_lang" )
    done

    while read -r installed_ext; do
        [ -z "$installed_ext" ] && continue

        local installed_ext_lower="${installed_ext,,}"

        local should_keep=false

        if grep -qix "$installed_ext_lower" "$path_to_vscode_extensions_base"; then
            continue
        fi

        for ext_for_target_lang in ${vscode_extensions_for_target_lang}; do
            if [ "$installed_ext_lower" == "${ext_for_target_lang,,}" ]; then
                should_keep=true
                break
            fi
        done

        if ! $should_keep; then
            code --uninstall-extension "$installed_ext"
            continue
        fi
    done < $path_to_list_of_current_installed_extensions

    echo "CURRENT_ACTIVE_LANGUAGE=$target_lang" > $PATH_TO_DOT_ENV_FILE
    printf "%s\n" "${just_installed_extensions[@]}" > "$path_to_list_of_current_installed_extensions"
    echo "[language-specific-extensions] vscode extensions for \"$target_lang\" is active"
}

print_separator() {
    printf '%*s\n' "$(tput cols)" '' | tr ' ' '-'
}

check_path() {
    declare -r some_path="$1"

    if [ -d "$some_path" ]; then
        echo "$some_path is DIREKTORY"
    elif [ -f "$some_path" ]; then
        echo "$some_path is FILE"
    else
        echo "$some_path not found"
    fi
}

if [ "$1" == "print_separator" ]; then
    print_separator
fi

if [ "$1" == "check_path" ]; then
    check_path "$2"
fi

if [ "$1" == "get_docker_image" ]; then
    get_docker_image "$2"
fi

if [ "$1" == "setup_language_specific_vscode_extensions" ]; then
    setup_language_specific_vscode_extensions "$2"
fi
