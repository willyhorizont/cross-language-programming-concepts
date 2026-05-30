languages = [
    [
        "javascript",
        "JavaScript",
        "https://nodejs.org/",
        ".js"
    ],
    [
        "python",
        "Python",
        "https://www.python.org/",
        ".py"
    ],
    [
        "php",
        "PHP",
        "https://www.php.net/",
        ".php"
    ],
    [
        "go",
        "GO",
        "https://go.dev/",
        ".go"
    ],
    [
        "perl",
        "Perl",
        "https://www.perl.org/",
        ".pl"
    ],
    [
        "julia",
        "Julia",
        "https://julialang.org/",
        ".jl"
    ],
    [
        "lua",
        "Lua",
        "https://www.lua.org/",
        ".lua"
    ],
    [
        "ruby",
        "Ruby",
        "https://www.ruby-lang.org/",
        ".rb"
    ],
    [
        "r",
        "R",
        "https://www.r-project.org/",
        ".r"
    ],
    [
        "kotlin",
        "Kotlin",
        "https://kotlinlang.org/",
        ".kt"
    ],
    [
        "swift",
        "Swift",
        "https://www.swift.org/",
        ".swift"
    ],
    [
        "dart",
        "Dart",
        "https://dart.dev/",
        ".dart"
    ],
    [
        "visual-basic-dot-net",
        "VB.NET",
        "https://learn.microsoft.com/en-us/dotnet/visual-basic/",
        ".vb"
    ],
    [
        "c-sharp",
        "C#",
        "https://learn.microsoft.com/en-us/dotnet/csharp/",
        ".cs"
    ],
    [
        "matlab",
        "MATLAB",
        "https://www.mathworks.com/products/matlab.html",
        ".m"
    ],
    [
        "gnu-octave",
        "GNU Octave",
        "https://octave.org/",
        ".m"
    ],
    [
        "wolfram-language-script",
        "Wolfram Language Script",
        "https://www.wolfram.com/wolframscript/",
        ".wls"
    ],
    [
        "raku",
        "Raku",
        "https://raku.org/",
        ".raku"
    ],
    [
        "scala",
        "Scala",
        "https://www.scala-lang.org/",
        ".scala"
    ],
    [
        "java",
        "Java",
        "https://www.oracle.com/java/",
        ".java"
    ],
    [
        "nu",
        "Nu",
        "https://www.nushell.sh/",
        ".nu"
    ],
    [
        "elv",
        "Elv",
        "https://elv.sh/",
        ".elv"
    ],
    [
        "vim9script",
        "Vim9 Script",
        "https://vimhelp.org/vim9.txt.html",
        ".vim"
    ],
    [
        "rust",
        "Rust",
        "https://rust-lang.org/",
        ".rs"
    ],
    [
        "nix",
        "Nix",
        "https://nixos.org/",
        ".nix"
    ],
    [
        "tcl",
        "Tcl",
        "https://www.tcl-lang.org/",
        ".tcl"
    ],
    [
        "gdscript",
        "GDScript",
        "https://docs.godotengine.org/en/4.6/tutorials/scripting/gdscript/gdscript_basics.html",
        ".gd"
    ],
]

titles = [
    ["cross-language-features", None],
    ["comments", None],
    ["hello-world", None],
    ["conditionals", None],
    ["loops", None],
    ["functions", None],
    ["error-handling", None],
    ["python-like list", None],
    ["python-like Dict", None],
    ["loop-through-each-list-item", None],
    ["get-is-any-item-in-list-matching-condition", "(some / any / exists / contains / includes)"],
    ["get-is-all-item-in-list-matching-condition", "(every / all)"],
    ["get-first-list-item-matching-condition", "(find)"],
    ["get-index-of-list-item-matching-condition", "(findIndex)"],
    ["get-all-list-item-matching-condition", "(filter / grep)"],
    ["transform-each-list-item", "(map / apply)"],
    ["combine-all-list-item", "(reduce / fold / aggregate)"],
]

base_url = "https://github.com/willyhorizont/cross-language-programming-concepts/tree/main/languages/"


def generate_languages():
    zxc = "\n".join([f"{number}. [{language[1]}]({language[2]}) <—> [{language[2]}]({language[2]})  " for number, language in enumerate(languages, start=1)])
    return zxc
    # with open("repo-utils-output-languages.txt", "w") as file:
    #     file.write(zxc)


def generate_programming_concepts():
    fgh = lambda title, language: f"{base_url}{language[0]}/{title[0]}{language[3]}"
    zxc = lambda title: "\n".join([f"  {number}. [{language[1]}]({fgh(title, language)})  " for number, language in enumerate(languages, start=1)])
    qwe = lambda title: f"{title[0]} {title[1]}" if title[1] else f"{title[0]}"
    asd = "\n\n---\n\n".join([f"### {qwe(title)}  \n{zxc(title)}" for title in titles])
    return asd
    # with open("repo-utils-output-programming-concepts.txt", "w") as file:
    #     file.write(asd)


def generate_readme(new_languages, new_programming_concepts):
    return f"""
# cross-language-programming-concepts

Cross-language implementations of common programming concepts, data structures, algorithms, and patterns. Rewrite of [https://github.com/willyhorizont/learn_programming_languages_with_javascript](https://github.com/willyhorizont/learn_programming_languages_with_javascript)

## Requirements

- [Docker Engine](https://docs.docker.com/engine/install/)
- [Git](https://git-scm.com/)

---
## Recommended environment

- GNU/Linux or GNU+Linux
- Visual Studio Code + [Code Runner](https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)

---

## Run command example

```bash
chmod +x docker/javascript/setup.sh
bash ./runner/javascript/run.sh hello-world.js
```

---

## Languages  
{new_languages}

## Programming concepts  

{new_programming_concepts}

"""


if __name__ == "__main__":
    generated_readme = generate_readme(generate_languages(), generate_programming_concepts())
    with open("README.test.md", "w") as file:
        file.write(generated_readme)
