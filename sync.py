from pathlib import Path
import json


def main():
    with open("languages.json", "r", encoding="utf-8") as file:
        languages = json.load(file)
        for language in languages:
            Path(f'languages/{language["id"]}').mkdir(parents=True, exist_ok=True)


if __name__ == "__main__":
    main()
