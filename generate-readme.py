import json


with open("languages.json", "r") as file:
    languages = json.load(file)

base_url = "https://github.com/willyhorizont/cross-language-programming-concepts/tree/main/languages/"


def generate_programming_concepts():
    with open("concepts.json", "r") as file:
        concepts = json.load(file)
    manage_concept_per_language_definition = lambda concept, language: "" if not (len(language) >= 5) else ("" if not (programming_concept := language[4].get(concept[0])) else f" : {programming_concept}")
    manage_concept_per_language_link = lambda concept, language: f"{base_url}{language[0]}/{concept[0]}{language[3]}"
    manage_concept_per_language = lambda concept: "\n".join([f"  {number}. [{language[1]}]({manage_concept_per_language_link(concept, language)}){manage_concept_per_language_definition(concept, language)}  " for number, language in enumerate(languages, start=1)])
    manage_concept_title = lambda concept: f"{concept[0]} {concept[1]}" if concept[1] else f"{concept[0]}"
    return "\n\n---\n\n".join([f"### {manage_concept_title(concept)}  \n{manage_concept_per_language(concept)}" for concept in concepts])


def main():
    generate_languages = lambda: "\n".join([f"{number}. [{language[1]}]({language[2]}) : [{language[2]}]({language[2]})  " for number, language in enumerate(languages, start=1)])
    generated_readme = (f"""
# cross-language-programming-concepts

Cross-language implementations of common programming concepts, data structures, algorithms, and patterns. Rewrite of [https://github.com/willyhorizont/learn_programming_languages_with_javascript](https://github.com/willyhorizont/learn_programming_languages_with_javascript)

## Requirements

- [Docker Engine](https://docs.docker.com/engine/install/)
- [Git](https://git-scm.com/)

---
## Recommended environment

- [GNU/Linux or GNU+Linux](https://linuxmint.com/download_lmde.php)
- [Visual Studio Code](https://code.visualstudio.com/) + [Code Runner](https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)

---

## Run

```bash
bash ./languages/<language>/run.sh ./languages/<language>/<file-name>.<file-extension>
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
