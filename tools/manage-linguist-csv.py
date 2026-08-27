import csv


def add_line_numbers(src: str, dest: str, delim: str = "|") -> None:
    with open(src, "r", encoding="utf-8") as f_in, open(dest, "w", encoding="utf-8", newline="") as f_out:
        reader = csv.reader(f_in, delimiter=delim)
        writer = csv.writer(f_out, delimiter=delim)
        header = next(reader, None)
        if header:
            writer.writerow([k.strip() for k in header] + ["xl order number"])
        for i, row in enumerate(reader, start=1):
            writer.writerow([k.strip() for k in row] + [""])


if __name__ == "__main__":
    add_line_numbers("../linguist-programming-languages-1.csv", "../linguist-programming-languages-2.csv")
