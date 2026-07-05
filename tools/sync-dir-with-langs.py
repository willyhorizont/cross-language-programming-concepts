from pathlib import Path
import json


def main():
    with open("../languages.json", "r", encoding="utf-8") as fb:
        ll = json.load(fb)
        for l in ll:
            Path(f'../languages/{l["id"]}').mkdir(parents=True, exist_ok=True)


if __name__ == "__main__":
    main()
