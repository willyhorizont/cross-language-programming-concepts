#!/bin/bash

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
# code --profile "tcl" .
# bash -c 'code --profile "tcl" .'
for lang in "${language_specific_vscode_extensions[@]}"; do
    echo "$lang"
    code --profile "$lang"
done
