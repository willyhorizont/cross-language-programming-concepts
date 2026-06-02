#!/bin/bash

[ -f ".env" ] && source ".env"

setup_language_specific_vscode_extensions() {
    local -r target_lang="${1:-"base"}"
    if [ "$CURRENT_ACTIVE_LANGUAGE" == "$target_lang" ]; then
        echo "[language specific extensions] vscode extension for \"$target_lang\" is active"
        return 0
    fi
    declare -A vscode_extensions
    vscode_extensions["base"]=$(cat 'vscode-extensions-base.txt' | xargs)
    if ! command -v jq &> /dev/null; then
        echo "jq not installed. installing jq..."
        sudo apt update && sudo apt install -y jq
    fi
    mapfile -t langs_from_json < <(jq -r '.[] | .[0]' "languages.json")

    for lang_from_json in "${langs_from_json[@]}"; do
        lang_exts_from_json=$(jq -r --arg b "$lang_from_json" '.[] | select(.[0] == $b) | .[5] | .[]' "languages.json" | xargs)
        vscode_extensions_for_lang_from_json="\
            ${vscode_extensions['base']} \

            $lang_exts_from_json \
        "

        vscode_extensions["$lang_from_json"]=$(echo "$vscode_extensions_for_lang_from_json" | xargs)
    done

    declare -a language_specific_vscode_extensions
    mapfile -t language_specific_vscode_extensions < <(jq -r '.[] | .[0]' "languages.json")

    local supported_vscode_extensions="\
        ${vscode_extensions['base']} \
    "
    for lang in "${language_specific_vscode_extensions[@]}"; do
        if [ -n "${vscode_extensions[$lang]}" ]; then
            supported_vscode_extensions="\
                $supported_vscode_extensions \
                ${vscode_extensions[$lang]} \
            "
        fi
    done
    vscode_extensions["supported"]=$(echo "$supported_vscode_extensions" | xargs | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | sort -u | xargs)
    # vscode_extensions["supported"]=$(echo "$supported_vscode_extensions" | xargs | tr ' ' '\n' | sort -u | xargs)
    # vscode_extensions["supported"]=$(echo "$supported_vscode_extensions" | xargs)

    local selected_lang="base"
    for lang in "${language_specific_vscode_extensions[@]}"; do
        if [ "$lang" == "$target_lang" ]; then
            selected_lang="$lang"
            break
        fi
    done

    local matched_lang="base"
    if [ -n "${vscode_extensions[$selected_lang]}" ]; then
        matched_lang="$selected_lang"
    fi

    declare -a just_installed_extensions=()
    mapfile -t just_installed_extensions < "vscode-extensions-base.txt"
    local current_installed_extensions="vscode-extensions-current.txt"
    code --list-extensions 2>/dev/null | grep -v -E "(stdin|Usage|Options)" > "$current_installed_extensions"

    for target_ext in ${vscode_extensions[$matched_lang]}; do
        if grep -qix "$target_ext" "$current_installed_extensions"; then
        # if grep -qx "$target_ext" "$current_installed_extensions"; then
            # echo "[language specific extensions] $target_ext already installed"
            continue
        fi
        # echo "[language specific extensions] installing $target_ext..."
        code --install-extension "$target_ext" --force
        just_installed_extensions+=( "$target_ext" )
    done

    # code --list-extensions > "$current_installed_extensions" 2>/dev/null
    # # rm -f "$current_installed_extensions"

    local -a extensions_to_disable=()

    while read -r installed_ext; do
        [ -z "$installed_ext" ] && continue

        local installed_ext_lower="${installed_ext,,}"

        local is_in_current_lang=false
        for target_ext in ${vscode_extensions[$matched_lang]}; do
            if [ "$installed_ext_lower" == "${target_ext,,}" ]; then
            # if [ "$installed_ext" == "$target_ext" ]; then
                is_in_current_lang=true
                break
            fi
        done

        $is_in_current_lang && continue

        # local is_supported=false
        local should_keep=false

        for target_ext in ${vscode_extensions["supported"]}; do
            if [ "$installed_ext_lower" == "${target_ext,,}" ]; then
            # if [ "$installed_ext" == "$target_ext" ]; then
                # is_supported=true
                should_keep=false
                break
            fi
        done

        # if $is_supported; then
        #     # echo "[language specific extensions] disabling $installed_ext..."
        #     # code --disable-extension "$installed_ext" -r .
        #     extensions_to_disable+=("$installed_ext")
        #     continue
        # fi
        # if ! $is_supported; then
        if ! $should_keep; then
            # echo "[language specific extensions] uninstalling $installed_ext..."
            code --uninstall-extension "$installed_ext"
            continue
        fi
    # done < <(code --list-extensions 2>/dev/null | grep -v -E "(stdin|Usage|Options)")
    done < $current_installed_extensions

    # rm -f "$current_installed_extensions"
    echo "CURRENT_ACTIVE_LANGUAGE=$selected_lang" > ".env"
    printf "%s\n" "${just_installed_extensions[@]}" > "vscode-extensions-current.txt"
    echo "[language specific extensions] switched to $selected_lang"
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

if [ "$1" == "setup_language_specific_vscode_extensions" ]; then
    setup_language_specific_vscode_extensions "$2"
fi
