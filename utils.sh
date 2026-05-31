#!/bin/bash

declare -a vscode_extensions_base=(
    "alecghost.tree-sitter-vscode"
    "evgeniypeshkov.syntax-highlighter"

    "formulahendry.code-runner"
    "aaron-bond.better-comments"
    "adpyke.codesnap"
    "cardinal90.multi-cursor-case-preserve"
    "christian-kohler.path-intellisense"
    "mechatroner.rainbow-csv"
    "naumovs.color-highlight"
    "oderwat.indent-rainbow"
    "ritwickdey.liveserver"
    "hjb2012.vscode-es6-string-html"
    "tobermory.es6-string-html"
    "vscode-icons-team.vscode-icons"
    "ms-vscode.cpptools-themes"
    "wholroyd.jinja"
    "yzhang.markdown-all-in-one"
)
# "tomrijndorp.find-it-faster"

setup_language_specific_vscode_extensions() {
    local -r target_lang="$1"
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
    local vscode_profile
    for lang in "${language_specific_vscode_extensions[@]}"; do
        if [ "$lang" == "$target_lang" ]; then
            vscode_profile="$lang"
            break
        fi
    done
    declare -a vscode_extensions_for_kotlin=()
    vscode_extensions_for_kotlin+=( "${vscode_extensions_base[@]}" )
    vscode_extensions_for_kotlin+=(
        "fwcd.kotlin"
        "mathiasfrohlich.Kotlin"
        "esafirm.kotlin-formatter"
    )
    declare -a vscode_extensions_for_nu=()
    vscode_extensions_for_nu+=( "${vscode_extensions_base[@]}" )
    vscode_extensions_for_nu+=(
        "TheNuProjectContributors.vscode-nushell-lang"
    )
    code --list-extensions > "vscode-extensions-backup.txt" 2>/dev/null
    # code --profile "$vscode_profile" --list-extensions > "vscode-extensions-for-$vscode_profile.txt" 2>/dev/null
    local vscode_extensions_array_name="vscode_extensions_for_${vscode_profile}"
    declare -n target_extensions_array="$vscode_extensions_array_name"
    code --profile "$vscode_profile" --list-extensions > "vscode-extensions-temp.txt" 2>/dev/null

    for ext in "${target_extensions_array[@]}"; do
        if grep -qx "$ext" "vscode-extensions-temp.txt" 2>/dev/null; then
            # echo "Extension $ext is already installed in profile [$vscode_profile]. Skipping..."
            continue
        fi
        # echo "Installing $ext vscode extension for profile [$vscode_profile]..."
        code --profile "$vscode_profile" --install-extension "$ext" --force
    done

    code --profile "$vscode_profile" --list-extensions > "vscode-extensions-for-$vscode_profile.txt" 2>/dev/null
    rm -f "vscode-extensions-temp.txt"

    echo "Opening VS Code with profile [$vscode_profile]..."
    code --profile "$vscode_profile"
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
