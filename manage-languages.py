import json

with open("languages.json", "r", encoding="utf-8") as file:
    languages = json.load(file)


def main():
    new_language = list(map((lambda language: ({
        "id": language[0],
        "name": language[1],
        "url": language[2],
        "file_extension": language[3],
        "concept_definition": language[4],
        "vscode_extensions": language[5],
        "vscode_extensions_archive": language[6],
        "docker": list(map((lambda docker_stuff: (({
            "language_version_notes": docker_stuff[0],
            "docker_images": docker_stuff[1],
        }) if (docker_stuff) else ({
            "language_version_notes": None,
            "docker_images": None,
        }))), language[7])),
    })), languages))
    with open("new-languages.json", "w", encoding="utf-8") as file:
        json.dump(new_language, file, indent=4)


if __name__ == "__main__":
    main()
