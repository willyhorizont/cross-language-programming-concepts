import json


with open("languages.json", "r") as file:
    languages = json.load(file)

titles = [
    ["cross-language-features", None],
    ["comments", None],
    ["hello-world", None],
    ["conditionals", None],
    ["loops", None],
    ["functions", None],
    ["error-handling", None],
    ["python-like-list", None],
    ["python-like-dict", None],
    ["loop-through-each-list-item", "(forEach)"],
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
    asd = "\n".join([f"{number}. [{language[1]}]({language[2]}) &lt;—&gt; [{language[2]}]({language[2]})  " for number, language in enumerate(languages, start=1)])
    return asd
    # with open("repo-utils-output-languages.txt", "w") as file:
    #     file.write(asd)


def generate_programming_concepts():
    rty = lambda title, language: "" if not (len(language) >= 5) else ("" if not (programming_concept := language[4].get(title[0])) else f" : {programming_concept}")
    fgh = lambda title, language: f"{base_url}{language[0]}/{title[0]}{language[3]}"
    zxc = lambda title: "\n".join([f"  {number}. [{language[1]}]({fgh(title, language)}){rty(title, language)}  " for number, language in enumerate(languages, start=1)])
    qwe = lambda title: f"{title[0]} {title[1]}" if title[1] else f"{title[0]}"
    asd = "\n\n---\n\n".join([f"### {qwe(title)}  \n{zxc(title)}" for title in titles])
    return asd
    # with open("repo-utils-output-programming-concepts.txt", "w") as file:
    #     file.write(asd)


def main():
    generated_readme = (f"""
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
bash /languages/javascript/run.sh <path-to-code>.js
```

---

## Languages  
{generate_languages()}

## Programming concepts  

{generate_programming_concepts()}

""".strip() + "  \n")
    with open("README.md", "w") as file:
        file.write(generated_readme)


if __name__ == "__main__":
    main()
