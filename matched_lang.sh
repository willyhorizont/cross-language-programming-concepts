#!/bin/bash

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

matched_lang="base" 
for k in "${!vscode_extensions[@]}"; do
    if [[ $k =~ $selected_lang ]]; then
        matched_lang="$k"
        break
    fi
done

for item in ${vscode_extensions[$matched_lang]}; do
    echo "Item: $item"
done
