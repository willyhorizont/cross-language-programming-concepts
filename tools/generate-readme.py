import json

with open("../languages.json", "r", encoding="utf-8") as fb:
    ll = json.load(fb)

r_burl = "https://github.com/willyhorizont/cross-language-programming-concepts/tree/main/languages/"


def gplc():
    with open("../concepts.json", "r", encoding="utf-8") as fb:
        lc = json.load(fb)
    gcpld = lambda lic, lil: "" if not (pc := lil["concept_definition"].get(lic["id"])) else f" : {pc}"
    gcpll = lambda lic, lil: f"{r_burl}{lil['id']}/{lic['id']}{lil['file_extension']}"
    gcpl = lambda lic: "\n".join([f"  {n}. [{' / '.join(list(map(lambda s: s['name'], lil['stack'])))}]({gcpll(lic, lil)}){gcpld(lic, lil)}  " for n, lil in enumerate(ll, start=1)])
    gct = lambda lic: f"{lic['name']} {lic['concept_definition']}" if lic["concept_definition"] else f"{lic['name']}"
    return "\n\n---\n\n".join([f"### {gct(lic)}  \n{gcpl(lic)}" for lic in lc])


def main():
    gls = lambda lil: " / ".join(list(map(lambda lis: f"[{lis['name']}]({lis['url']})", lil['stack'])))
    gllu = lambda lil: " or ".join(list(map(lambda lis: f"[{lis['url']}]({lis['url']})", lil['stack'])))
    genll = lambda: "\n".join([f"{n}. {gls(lil)} : {gllu(lil)}  " for n, lil in enumerate(ll, start=1)])
    gendrm = (f"""
# cross-language-programming-concepts

Cross-language implementations of common programming concepts, data structures, algorithms, and patterns. Rewrite of [https://github.com/willyhorizont/learn_programming_languages_with_javascript](https://github.com/willyhorizont/learn_programming_languages_with_javascript)

## Requirements

- [Visual Studio Code](https://code.visualstudio.com/) + [Code Runner VSCode Extension](https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)

### Linux
- [Git](https://git-scm.com/install/linux)
- [Docker Engine](https://docs.docker.com/engine/install/)

### Windows
- [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
- [Git](https://git-scm.com/install/windows)
- [Docker Dekstop](https://docs.docker.com/desktop/setup/install/windows-install/)

---

## Languages

{genll()}

![GitHub Programming Languages Card](https://github.com/willyhorizont/cross-language-programming-concepts/blob/main/github-programming-languages-card.png)  

## Programming concepts

{gplc()}

## Trends

- [https://www.tiobe.com/tiobe-index/](https://www.tiobe.com/tiobe-index/)
- [https://pypl.github.io/PYPL.html](https://pypl.github.io/PYPL.html)
- [https://tjpalmer.github.io/languish/](https://tjpalmer.github.io/languish/)
""".strip() + "  \n")
    with open("../README.md", "w", encoding="utf-8") as fb:
        fb.write(gendrm)


if __name__ == "__main__":
    main()
