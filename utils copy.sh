#!/bin/bash

[ -f ".env" ] && source ".env"

setup_language_specific_vscode_extensions() {
    local -r target_lang="${1:-"base"}"
    if [ "$CURRENT_LANGUAGE" == "$target_lang" ]; then
        echo "[language specific extensions] vscode extension for \"$target_lang\" is active"
        return 0
    fi
    declare -A vscode_extensions
    vscode_extensions_base="\
        alecghost.tree-sitter-vscode \
        evgeniypeshkov.syntax-highlighter \

        formulahendry.code-runner \
        aaron-bond.better-comments \
        adpyke.codesnap \
        cardinal90.multi-cursor-case-preserve \
        christian-kohler.path-intellisense \
        mechatroner.rainbow-csv \
        naumovs.color-highlight \
        oderwat.indent-rainbow \
        ritwickdey.liveserver \
        hjb2012.vscode-es6-string-html \
        tobermory.es6-string-html \
        vscode-icons-team.vscode-icons \
        ms-vscode.cpptools-themes \
        wholroyd.jinja \
        yzhang.markdown-all-in-one \
    "
    # "tomrijndorp.find-it-faster"
    vscode_extensions["base"]=$(echo "$vscode_extensions_base" | xargs)

    vscode_extensions_for_kotlin="\
        ${vscode_extensions['base']} \

        fwcd.kotlin \
        mathiasfrohlich.Kotlin \
        esafirm.kotlin-formatter \
    "
    vscode_extensions["kotlin"]=$(echo "$vscode_extensions_for_kotlin" | xargs)

    vscode_extensions_for_nu="\
        ${vscode_extensions['base']} \

        TheNuProjectContributors.vscode-nushell-lang \
    "
    vscode_extensions["nu"]=$(echo "$vscode_extensions_for_nu" | xargs)

    vscode_extensions_for_elv="\
        ${vscode_extensions['base']} \

        elves.elvish \
    "
    vscode_extensions["elv"]=$(echo "$vscode_extensions_for_elv" | xargs)

    declare -a language_specific_vscode_extensions=(
        "javascript"
        "python"
        "php"
        "go"
        "perl"
        "julia"
        "lua"
        "ruby"
        "r"
        "kotlin"
        "swift"
        "dart"
        "visual-basic-dot-net"
        "c-sharp"
        "matlab"
        "gnu-octave"
        "wolfram-language-script"
        "raku"
        "scala"
        "java"
        "nu"
        "elv"
        "vim9script"
        "rust"
        "nix"
        "tcl"
        "gdscript"
    )

    local vscode_extensions_supported="\
        ${vscode_extensions['base']} \
    "
    for lang in "${language_specific_vscode_extensions[@]}"; do
        if [ -n "${vscode_extensions[$lang]}" ]; then
            vscode_extensions_supported="\
                $vscode_extensions_supported \
                ${vscode_extensions[$lang]} \
            "
        fi
    done
    # vscode_extensions["supported"]=$(echo "$vscode_extensions_supported" | xargs | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | sort -u | xargs)
    vscode_extensions["supported"]=$(echo "$vscode_extensions_supported" | xargs | tr ' ' '\n' | sort -u | xargs)
    # vscode_extensions["supported"]=$(echo "$vscode_extensions_supported" | xargs)

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

    local current_installed_extensions="vscode-extensions-current.txt"
    code --list-extensions 2>/dev/null | grep -v -E "(stdin|Usage|Options)" > "$current_installed_extensions"

    for target_ext in ${vscode_extensions[$matched_lang]}; do
        # if grep -qix "$target_ext" "$current_installed_extensions"; then
        if grep -qx "$target_ext" "$current_installed_extensions"; then
            echo "[language specific extensions] $target_ext already installed"
            continue
        fi
        echo "[language specific extensions] installing $target_ext..."
        code --install-extension "$target_ext" --force
    done

    # code --list-extensions > "$current_installed_extensions" 2>/dev/null
    rm -f "$current_installed_extensions"

    local -a extensions_to_disable=()

    while read -r installed_ext; do
        [ -z "$installed_ext" ] && continue

        # local installed_ext_lower="${installed_ext,,}"

        local is_in_current_lang=false
        for target_ext in ${vscode_extensions[$matched_lang]}; do
            # if [ "$installed_ext_lower" == "${target_ext,,}" ]; then
            if [ "$installed_ext" == "$target_ext" ]; then
                is_in_current_lang=true
                break
            fi
        done

        $is_in_current_lang && continue

        local is_supported=false

        for target_ext in ${vscode_extensions["supported"]}; do
            # if [ "$installed_ext_lower" == "${target_ext,,}" ]; then
            if [ "$installed_ext" == "$target_ext" ]; then
                is_supported=true
                break
            fi
        done

        if $is_supported; then
            # echo "[language specific extensions] disabling $installed_ext..."
            # code --disable-extension "$installed_ext" -r .
            extensions_to_disable+=("$installed_ext")
        else
            echo "[language specific extensions] uninstalling $installed_ext..."
            code --uninstall-extension "$installed_ext"
        fi
    done < <(code --list-extensions 2>/dev/null | grep -v -E "(stdin|Usage|Options)")

    sync_disabled_extensions "${extensions_to_disable[@]}"

    # rm -f "$current_installed_extensions"
    echo "CURRENT_LANGUAGE=$selected_lang" > ".env"
    echo "[language specific extensions] successfully switched to $selected_lang"
}

sync_disabled_extensions() {
    local settings_json=""
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        settings_json="$HOME/.config/Code/User/settings.json"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        settings_json="$HOME/Library/Application Support/Code/User/settings.json"
    else
        settings_json="$APPDATA/Code/User/settings.json"
    fi

    [ ! -f "$settings_json" ] && echo "{}" > "$settings_json"

    node -e "
    const fs = require('fs');
    const path = '$settings_json';
    const disabledList = process.argv.slice(1);

    let data = {};
    try {
        data = JSON.parse(fs.readFileSync(path, 'utf8'));
    } catch(e) {}

    data['extensions.disabledExtensions'] = disabledList;
    fs.writeFileSync(path, JSON.stringify(data, null, 4));
    " "${@}"
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
