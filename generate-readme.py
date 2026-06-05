import json

with open("languages.json", "r", encoding="utf-8") as file:
    languages = json.load(file)

base_url = "https://github.com/willyhorizont/cross-language-programming-concepts/tree/main/languages/"


def generate_programming_concepts():
    with open("concepts.json", "r", encoding="utf-8") as file:
        concepts = json.load(file)
    get_concept_per_language_definition = lambda concept, language: "" if not (programming_concept := language["concept_definition"].get(concept["concept_name"])) else f" : {programming_concept}"
    get_concept_per_language_link = lambda concept, language: f"{base_url}{language['id']}/{concept['concept_name']}{language['file_extension']}"
    get_concept_per_language = lambda concept: "\n".join([f"  {number}. [{language['name']}]({get_concept_per_language_link(concept, language)}){get_concept_per_language_definition(concept, language)}  " for number, language in enumerate(languages, start=1)])
    get_concept_title = lambda concept: f"{concept['concept_name']} {concept['concept_definition']}" if concept["concept_definition"] else f"{concept['concept_name']}"
    return "\n\n---\n\n".join([f"### {get_concept_title(concept)}  \n{get_concept_per_language(concept)}" for concept in concepts])


def main():
    generate_languages = lambda: "\n".join([f"{number}. [{language['name']}]({language['url']}) : [{language['url']}]({language['url']})  " for number, language in enumerate(languages, start=1)])
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
    with open("README.md", "w", encoding="utf-8") as file:
        file.write(generated_readme)


if __name__ == "__main__":
    main()
