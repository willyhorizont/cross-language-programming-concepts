use fmt;

export fn greet_girl(va: str...) void = {
	let gn = va[0];
	let pretty = if (len(va) > 1z) va[1] else "false";
	if (pretty == "true") {
		fmt::print("Hi pretty ")!;
		fmt::println(gn)!;
        return;
	};
    fmt::print("Hi ")!;
    fmt::println(gn)!;
};

export type entry = struct {
	key: str,
	value: int,
};

export fn map_get(map: []entry, search_key: str) (int | void) = {
	for (let i = 0z; i < len(map); i += 1) {
		if (map[i].key == search_key) {
			return map[i].value;
		};
	};
	return;
};
