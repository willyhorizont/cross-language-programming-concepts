#!/bin/bash

C="${1:-$0}"
shift

SD="$(dirname "$(realpath "$C")")"

LID="$(basename "$SD")"
if [ -z "$1" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$LID"
    exit 1
fi

RD="$(realpath "$SD/../..")"
RN="$(basename "$RD")"

PTFNX="$1"
if [[ "$PTFNX" == ./* ]]; then
    PTFNX="$RD/${PTFNX#./}"
fi
PTFNXD="$(dirname "$PTFNX")"
FNX="$(basename "$PTFNX")"
FN="${FNX%.*}"
FX="${FNX##*.}"

PTTFNXD="$RD/runtimes/$LID"

LEF="$RD/.env.$LID"

if [ -f "$LEF" ]; then
    source "$LEF"
fi

IMG=$("$RD/tools/utils.sh" --get-docker-image $LID 2>/dev/null)

L=$("$RD/tools/utils.sh" --print-sep)

PTDCNTFNX="$RD/active-docker-container.txt"

XPECT_FX=$("$RD/tools/utils.sh" --get-lang-ext $LID 2>/dev/null)

if [[ "$XPECT_FX" == ".rs" ]]; then
    if [[ ".$FX" == ".as" ]]; then
        bash "$RD/languages/actionscript/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".c3" ]]; then
        bash "$RD/languages/c3/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".cj" ]]; then
        bash "$RD/languages/cangjie/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".d" ]]; then
        bash "$RD/languages/d/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".erl" ]]; then
        bash "$RD/languages/erlang/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".gleam" ]]; then
        bash "$RD/languages/gleam/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".kt" ]]; then
        bash "$RD/languages/kotlin/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".m" ]]; then
        bash "$RD/languages/matlab-or-octave/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".nim" ]]; then
        bash "$RD/languages/nim/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".ml" ]]; then
        bash "$RD/languages/ocaml/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".odin" ]]; then
        bash "$RD/languages/odin/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".pike" ]]; then
        bash "$RD/languages/pike/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".tcl" ]]; then
        bash "$RD/languages/tcl/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".v" ]]; then
        bash "$RD/languages/v/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vala" ]]; then
        bash "$RD/languages/vala/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vim" ]]; then
        bash "$RD/languages/vim-script/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".wl" ]]; then
        bash "$RD/languages/wolfram-language-mathematica/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".wren" ]]; then
        bash "$RD/languages/wren/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".groovy" ]]; then
    if [[ ".$FX" == ".as" ]]; then
        bash "$RD/languages/actionscript/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".c3" ]]; then
        bash "$RD/languages/c3/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".cj" ]]; then
        bash "$RD/languages/cangjie/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".d" ]]; then
        bash "$RD/languages/d/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".erl" ]]; then
        bash "$RD/languages/erlang/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".kt" ]]; then
        bash "$RD/languages/kotlin/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".st" ]]; then
        bash "$RD/languages/smalltalk/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".typ" ]]; then
        bash "$RD/languages/typst/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".wl" ]]; then
        bash "$RD/languages/wolfram-language-mathematica/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".go" ]]; then
    if [[ ".$FX" == ".as" ]]; then
        bash "$RD/languages/actionscript/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".c3" ]]; then
        bash "$RD/languages/c3/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".cj" ]]; then
        bash "$RD/languages/cangjie/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".d" ]]; then
        bash "$RD/languages/d/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".erl" ]]; then
        bash "$RD/languages/erlang/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".gd" ]]; then
        bash "$RD/languages/gdscript/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".m" ]]; then
        bash "$RD/languages/matlab-or-octave/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".odin" ]]; then
        bash "$RD/languages/odin/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".pike" ]]; then
        bash "$RD/languages/pike/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".tcl" ]]; then
        bash "$RD/languages/tcl/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".v" ]]; then
        bash "$RD/languages/v/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vala" ]]; then
        bash "$RD/languages/vala/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vim" ]]; then
        bash "$RD/languages/vim-script/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".wren" ]]; then
        bash "$RD/languages/wren/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".swift" ]]; then
    if [[ ".$FX" == ".as" ]]; then
        bash "$RD/languages/actionscript/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".c3" ]]; then
        bash "$RD/languages/c3/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".cj" ]]; then
        bash "$RD/languages/cangjie/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".d" ]]; then
        bash "$RD/languages/d/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".gleam" ]]; then
        bash "$RD/languages/gleam/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".kt" ]]; then
        bash "$RD/languages/kotlin/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".scala" ]]; then
        bash "$RD/languages/scala/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".raku" ]]; then
        bash "$RD/languages/raku/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".cpp" ]]; then
    if [[ ".$FX" == ".as" ]]; then
        bash "$RD/languages/actionscript/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".c3" ]]; then
        bash "$RD/languages/c3/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".d" ]]; then
        bash "$RD/languages/d/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".m" ]]; then
        bash "$RD/languages/matlab-or-octave/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".ml" ]]; then
        bash "$RD/languages/ocaml/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".tcl" ]]; then
        bash "$RD/languages/tcl/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vim" ]]; then
        bash "$RD/languages/vim-script/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".wl" ]]; then
        bash "$RD/languages/wolfram-language-mathematica/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".wren" ]]; then
        bash "$RD/languages/wren/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".zig" ]]; then
        bash "$RD/languages/zig/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".m" ]]; then
    if [[ ".$FX" == ".as" ]]; then
        bash "$RD/languages/actionscript/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".c3" ]]; then
        bash "$RD/languages/c3/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".d" ]]; then
        bash "$RD/languages/d/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".zig" ]]; then
        bash "$RD/languages/zig/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".raku" ]]; then
        bash "$RD/languages/raku/runner.sh" "$1"
        exit 0
    fi
    # if [[ ".$FX" == ".m" ]]; then
    #     # continue
    # fi
fi

if [[ "$XPECT_FX" == ".cs" ]]; then
    if [[ ".$FX" == ".as" ]]; then
        bash "$RD/languages/actionscript/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".c3" ]]; then
        bash "$RD/languages/c3/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".cj" ]]; then
        bash "$RD/languages/cangjie/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".d" ]]; then
        bash "$RD/languages/d/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".m" ]]; then
        bash "$RD/languages/matlab-or-octave/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".tcl" ]]; then
        bash "$RD/languages/tcl/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vala" ]]; then
        bash "$RD/languages/vala/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vim" ]]; then
        bash "$RD/languages/vim-script/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".dart" ]]; then
    if [[ ".$FX" == ".as" ]]; then
        bash "$RD/languages/actionscript/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".c3" ]]; then
        bash "$RD/languages/c3/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".d" ]]; then
        bash "$RD/languages/d/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".gd" ]]; then
        bash "$RD/languages/gdscript/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".typ" ]]; then
        bash "$RD/languages/typst/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".zig" ]]; then
        bash "$RD/languages/zig/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".java" ]]; then
    if [[ ".$FX" == ".d" ]]; then
        bash "$RD/languages/d/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".gd" ]]; then
        bash "$RD/languages/gdscript/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".typ" ]]; then
        bash "$RD/languages/typst/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".wl" ]]; then
        bash "$RD/languages/wolfram-language-mathematica/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".zig" ]]; then
        bash "$RD/languages/zig/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".raku" ]]; then
        bash "$RD/languages/raku/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".rb" ]]; then
    if [[ ".$FX" == ".cr" ]]; then
        bash "$RD/languages/crystal/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".exs" ]]; then
        bash "$RD/languages/elixir/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".nix" ]]; then
        bash "$RD/languages/nix/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".c" ]]; then
    if [[ ".$FX" == ".odin" ]]; then
        bash "$RD/languages/odin/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".wl" ]]; then
        bash "$RD/languages/wolfram-language-mathematica/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".js" ]]; then
    if [[ ".$FX" == ".odin" ]]; then
        bash "$RD/languages/odin/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vala" ]]; then
        bash "$RD/languages/vala/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vim" ]]; then
        bash "$RD/languages/vim-script/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".jl" ]]; then
    if [[ ".$FX" == ".cr" ]]; then
        bash "$RD/languages/crystal/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".exs" ]]; then
        bash "$RD/languages/elixir/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".elv" ]]; then
        bash "$RD/languages/elvish/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".nix" ]]; then
        bash "$RD/languages/nix/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".nu" ]]; then
        bash "$RD/languages/nu/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".ml" ]]; then
        bash "$RD/languages/ocaml/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".ps1" ]]; then
    if [[ ".$FX" == ".cr" ]]; then
        bash "$RD/languages/crystal/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".exs" ]]; then
        bash "$RD/languages/elixir/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".nix" ]]; then
        bash "$RD/languages/nix/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".nu" ]]; then
        bash "$RD/languages/nu/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".py" ]]; then
    if [[ ".$FX" == ".cr" ]]; then
        bash "$RD/languages/crystal/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".elv" ]]; then
        bash "$RD/languages/elvish/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".zig" ]]; then
        bash "$RD/languages/zig/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".r" ]]; then
    if [[ ".$FX" == ".elv" ]]; then
        bash "$RD/languages/elvish/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".raku" ]]; then
        bash "$RD/languages/raku/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".pl" ]]; then
    if [[ ".$FX" == ".nu" ]]; then
        bash "$RD/languages/nu/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".raku" ]]; then
    if [[ ".$FX" == ".elv" ]]; then
        bash "$RD/languages/elvish/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".nu" ]]; then
        bash "$RD/languages/nu/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".lua" ]]; then
    if [[ ".$FX" == ".as" ]]; then
        bash "$RD/languages/actionscript/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".m" ]]; then
        bash "$RD/languages/matlab-or-octave/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".nix" ]]; then
        bash "$RD/languages/nix/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".ml" ]]; then
        bash "$RD/languages/ocaml/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".odin" ]]; then
        bash "$RD/languages/odin/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".scala" ]]; then
        bash "$RD/languages/scala/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".tcl" ]]; then
        bash "$RD/languages/tcl/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".v" ]]; then
        bash "$RD/languages/v/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vala" ]]; then
        bash "$RD/languages/vala/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vim" ]]; then
        bash "$RD/languages/vim-script/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".wren" ]]; then
        bash "$RD/languages/wren/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".zig" ]]; then
        bash "$RD/languages/zig/runner.sh" "$1"
        exit 0
    fi
fi

if [[ "$XPECT_FX" == ".vb" ]]; then
    if [[ ".$FX" == ".m" ]]; then
        bash "$RD/languages/matlab-or-octave/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".nix" ]]; then
        bash "$RD/languages/nix/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".scala" ]]; then
        bash "$RD/languages/scala/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vala" ]]; then
        bash "$RD/languages/vala/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".vim" ]]; then
        bash "$RD/languages/vim-script/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".wl" ]]; then
        bash "$RD/languages/wolfram-language-mathematica/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".wren" ]]; then
        bash "$RD/languages/wren/runner.sh" "$1"
        exit 0
    fi
    if [[ ".$FX" == ".zig" ]]; then
        bash "$RD/languages/zig/runner.sh" "$1"
        exit 0
    fi
fi

# if [[ "$XPECT_FX" == ".php" ]]; then fi
