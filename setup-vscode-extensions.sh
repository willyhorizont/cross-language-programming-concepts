#!/bin/bash

declare -a vscode_extensions_default=(
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
    "tomrijndorp.find-it-faster"
    "vscode-icons-team.vscode-icons"
    "wholroyd.jinja"
    "yzhang.markdown-all-in-one"
)

declare -a vscode_extensions_kotlin=()
vscode_extensions_kotlin+=( "${vscode_extensions_default[@]}" )
vscode_extensions_kotlin+=(
    "fwcd.kotlin"
    "mathiasfrohlich.Kotlin"
    "esafirm.kotlin-formatter"
)

setup_vscode_extensions_kotlin() {
    for i in "${!vscode_extensions_kotlin[@]}"; do
        code --profile "kotlin" --install-extension "${vscode_extensions_kotlin[$i]}" --force
    done
}


# code --profile "$vscode_profile" --install-extension "$vscode_extension_id" --force &> /dev/null
# code --profile "$vscode_profile" --uninstall-extension "$vscode_extension_id" --force &> /dev/null
# code --profile "$vscode_profile" --list-extensions
