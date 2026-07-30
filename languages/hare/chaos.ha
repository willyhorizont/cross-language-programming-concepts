use fmt;
use willyhorizont::runtime::xl;

fn eksekusi_lambda(ctx: *struct { faktor: int }, angka: int) int = {
    return angka * ctx.faktor;
};

export fn main() void = {
    fmt::println("hello, world")!;
    xl::greet_girl("Alisa", "true");
    xl::greet_girl("Mia");

	let list: []int = [];
	defer free(list);
	append(list, 10)!;
	append(list, 20)!;
	append(list, 30)!;
	fmt::print("Ukuran list saat ini: ")!;
	fmt::println(len(list))!; // Output: 3
	fmt::print("Elemen indeks ke-1: ")!;
	fmt::println(list[1])!; // Output: 20

	let my_map: []xl::entry = [];
	defer free(my_map);
	append(my_map, xl::entry { key = "Alisa", value = 23 })!;
	append(my_map, xl::entry { key = "Mia", value = 20 })!;
	append(my_map, xl::entry { key = "Chloe", value = 25 })!;
    let my_map: []xl::entry = [];
	defer free(my_map);
	append(my_map, xl::entry { key = "Alisa", value = 23 })!;
	append(my_map, xl::entry { key = "Mia", value = 20 })!;
	append(my_map, xl::entry { key = "Chloe", value = 25 })!;
	let target = "Mia";
	match (xl::map_get(my_map, target)) {
	case let val: int =>
		fmt::print("Umur ")!;
		fmt::print(target)!;
		fmt::print(" adalah: ")!;
		fmt::println(val)!;
	case void =>
		fmt::println("Kunci tidak ditemukan!")!;
	};

	let mul_by_5 = struct { faktor: int = 5 };
	let mul_by_10 = struct { faktor: int = 10 };
	let hasil1 = eksekusi_lambda(&mul_by_5, 6);
	let hasil2 = eksekusi_lambda(&mul_by_10, 6);
	fmt::print("Hasil 6 dikali objek anonim faktor 5  = ")!;
	fmt::println(hasil1)!; // Output: 30
	fmt::print("Hasil 6 dikali objek anonim faktor 10 = ")!;
	fmt::println(hasil2)!; // Output: 60
};
