#!/bin/bash

if [ -z "$1" ]; then
    echo "usage: $0 /path/to/target_file"
    exit 1
fi

TARGET_FILE="$(realpath "$1")"

EXT=".${TARGET_FILE##*.}"

declare -A MAP

MAP[".js"]="javascript-or-typescript"
MAP[".py"]="python"
MAP[".php"]="php"
MAP[".go"]="go"
MAP[".pl"]="perl"
MAP[".jl"]="julia"
MAP[".lua"]="lua"
MAP[".rb"]="ruby"
MAP[".r"]="r"
MAP[".kt"]="kotlin"
MAP[".swift"]="swift"
MAP[".dart"]="dart"
MAP[".vb"]="visual-basic-dot-net"
MAP[".cs"]="c-sharp"
MAP[".wl"]="wolfram-language-mathematica"
MAP[".raku"]="raku"
MAP[".scala"]="scala"
MAP[".java"]="java"
MAP[".nu"]="nu"
MAP[".elv"]="elvish"
MAP[".vim"]="vim-script"
MAP[".rs"]="rust"
MAP[".nix"]="nix"
MAP[".tcl"]="tcl"
MAP[".gd"]="gdscript"
MAP[".typ"]="typst"
MAP[".ps1"]="powershell"
MAP[".exs"]="elixir"
MAP[".ml"]="ocaml"
MAP[".erl"]="erlang"
MAP[".gleam"]="gleam"
MAP[".zig"]="zig"
MAP[".nim"]="nim"
MAP[".odin"]="odin"
MAP[".cpp"]="c-plus-plus"
MAP[".m"]="objective-c"
MAP[".st"]="smalltalk"
MAP[".as"]="actionscript"
MAP[".groovy"]="groovy"
MAP[".cj"]="cangjie"
MAP[".c3"]="c3"
MAP[".c"]="c"
MAP[".d"]="d"
MAP[".v"]="v"
MAP[".vala"]="vala"
MAP[".cr"]="crystal"
MAP[".wren"]="wren"
MAP[".pike"]="pike"

LANG_ID="${MAP[$EXT]}"

if [ -z "$LANG_ID" ]; then
    echo "Error: File extension '$EXT' is not supported!"
    exit 1
fi

RUNNER_PATH="$HOME/willyhorizont.github.io/cross-language-programming-concepts/languages/$LANG_ID/runner.sh"

if [ -f "$RUNNER_PATH" ]; then
    echo "$RUNNER_PATH $TARGET_FILE"
    bash "$RUNNER_PATH" "$TARGET_FILE"
else
    echo "$RUNNER_PATH not found!"
    exit 1
fi

# sed -i '/alias xlrun=/d' ~/.bashrc && echo "alias xlrun='\$HOME/willyhorizont.github.io/cross-language-programming-concepts/xlrun.sh'" >> ~/.bashrc && source ~/.bashrc
