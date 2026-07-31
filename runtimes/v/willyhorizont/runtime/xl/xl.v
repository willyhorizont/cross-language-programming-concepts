module xl

pub struct None {}

pub fn (n None) str() string {
	return "none"
}

pub fn none() Type {
	return None{}
}

pub type Type = None | bool | string | int | i64 | f64 | []Type | map[string]Type | Lambda

pub struct Lambda {
pub:
	value fn (Type) Type @[required]
}

pub struct Iterator {
pub mut:
	value []Type
	index int
}

pub fn to_bool(v Type) bool {
	match v {
		bool {
			return v
		}
		else {
			panic("XlRuntimeError: Invalid arguments.")
		}
	}
}

pub fn to_string(v Type) string {
	match v {
		string {
			return v
		}
		bool {
			return v.str()
		}
		int {
			return v.str()
		}
		i64 {
			return v.str()
		}
		f64 {
			return v.str()
		}
		else {
			panic("XlRuntimeError: Invalid arguments.")
		}
	}
}

pub fn to_int(v Type) int {
	match v {
		int {
			return v
		}
		i64 {
			return int(v)
		}
		f64 {
			return int(v)
		}
		else {
			panic("XlRuntimeError: Invalid arguments.")
		}
	}
}

pub fn to_float(v Type) f64 {
	match v {
		f64 {
			return v
		}
		int {
			return f64(v)
		}
		i64 {
			return f64(v)
		}
		else {
			panic("XlRuntimeError: Invalid arguments.")
		}
	}
}

pub fn to_list(v Type) []Type {
	match v {
		[]Type {
			return v
		}
		else {
			panic("XlRuntimeError: Invalid arguments.")
		}
	}
}

pub fn to_dict(v Type) map[string]Type {
	match v {
		map[string]Type {
			return v
		}
		else {
			panic("XlRuntimeError: Invalid arguments.")
		}
	}
}

pub fn to_lambda(v Type) Lambda {
	match v {
		Lambda {
			return v
		}
		else {
			panic("XlRuntimeError: Invalid arguments.")
		}
	}
}

pub fn (v Type) to_bool() bool {
	match v {
		bool {
			return v
		}
		else {
			panic("XlRuntimeError: Expected Bool.")
		}
	}
}

pub fn (v Type) to_string() string {
	match v {
		string {
			return v
		}
		bool {
			return v.str()
		}
		int {
			return v.str()
		}
		i64 {
			return v.str()
		}
		f64 {
			return v.str()
		}
		else {
			panic("XlRuntimeError: Unsupported value.")
		}
	}
}

pub fn (v Type) to_int() int {
	match v {
		int {
			return v
		}
		i64 {
			return int(v)
		}
		f64 {
			return int(v)
		}
		else {
			panic("XlRuntimeError: Expected Int.")
		}
	}
}

pub fn (v Type) to_float() f64 {
	match v {
		f64 {
			return v
		}
		int {
			return f64(v)
		}
		i64 {
			return f64(v)
		}
		else {
			panic("XlRuntimeError: Expected Float.")
		}
	}
}

pub fn (v Type) to_list() []Type {
	match v {
		[]Type {
			return v
		}
		else {
			panic("XlRuntimeError: Expected List.")
		}
	}
}

pub fn (v Type) to_dict() map[string]Type {
	match v {
		map[string]Type {
			return v
		}
		else {
			panic("XlRuntimeError: Expected Dict.")
		}
	}
}

pub fn (v Type) to_lambda() Lambda {
	match v {
		Lambda {
			return v
		}
		else {
			panic("XlRuntimeError: Expected Lambda.")
		}
	}
}

pub fn (v Type) to[T]() T {
	if v is T {
		return v
	}
	panic("XlRuntimeError: Cannot unwrap Xl to ${typeof[T]().name}")
}

pub fn init(va ...Type) Type {
	if va.len == 0 {
		return None{}
	}
	return va[0]
}

pub fn lambda(v Lambda) Type {
	return v
}

pub fn iter(v Type) Iterator {
	mut itr := Iterator{}
	if v is []Type {
		itr.value = v
	}
	return itr
}

pub fn next(mut itr Iterator) Type {
	if itr.index >= itr.value.len {
		return false
	}
	v := itr.value[itr.index]
	itr.index += 1
	return v
}

pub fn (a Type) call(va ...Type) Type {
	if a is Lambda {
		return a.value(va)
	}
	panic("XlRuntimeError: Expected Lambda.")
}

pub fn (a Type) at(i int) Type {
	if a is []Type {
		if i < 0 || i >= a.len {
			panic("XlRuntimeError: List index ${i} out of bounds.")
		}
		return a[i]
	}
	panic("XlRuntimeError: Expected List.")
}

pub fn (mut a Type) push(nlel Type) {
	if mut a is []Type {
		a << nlel
		return
	}
	panic("XlRuntimeError: Expected List.")
}

pub fn (mut a Type) pop() Type {
	if mut a is []Type {
		if a.len == 0 {
			panic("XlRuntimeError: Cannot pop empty List.")
		}
		mut l := a.clone()
		lt := l.last()
		l.delete(l.len - 1)
		a = l
		return lt
	}
	panic("XlRuntimeError: Expected List.")
}

pub fn (a Type) get(pk string) Type {
	if a is map[string]Type {
		return a[pk] or {
			panic("XlRuntimeError: Key \"${pk}\" not found in Dict.")
		}
	}
	panic("XlRuntimeError: Expected Dict.")
}

fn escape_string(s string) string {
	mut r := s.replace("\\", "\\\\")
	r = r.replace("\"", "\\\"")
	r = r.replace("\n", "\\n")
	r = r.replace("\r", "\\r")
	r = r.replace("\t", "\\t")
	return r
}

pub struct JifyOpt {
pub:
	pretty bool
}

pub fn json_stringify(a Type, va ...JifyOpt) string {
	mut p := false
	if va.len > 0 && va[0].pretty {
		p = true
	}
	t := " ".repeat(4)
	mut s := init([init({ "t": init("v"), "v": a, "d": init(0) })])
	mut r := ""
	for s.to_list().len > 0 {
		c := s.pop()
		if c.get("t").to_string() == "r" {
			r += c.get("v").to_string()
			continue
		}
		v := c.get("v")
		cur_d := c.get("d").to_int()
		match v {
			None {
				r += "null"
				continue
			}
			bool {
				r += if v { "true" } else { "false" }
				continue
			}
			string {
				r += "\"" + escape_string(v) + "\""
				continue
			}
			int {
				r += v.str()
				continue
			}
			i64 {
				r += v.str()
				continue
			}
			f64 {
				r += v.str()
				continue
			}
			Lambda {
				r += "\"[object Function]\""
				continue
			}
			[]Type {
				if v.len == 0 {
					r += "[]"
					continue
				}
				child_d := cur_d + 1
				s.push(init({
					"t": init("r"),
					"v": init(if p { "\n" + t.repeat(cur_d) + "]" } else { "]" }),
					"d": init(cur_d),
				}))
				for i := v.len - 1; i >= 0; i -= 1 {
					s.push(init({
						"t": init("v"),
						"v": v[i],
						"d": init(child_d),
					}))
					if i > 0 {
						s.push(init({
							"t": init("r"),
							"v": init(if p { ",\n" + t.repeat(child_d) } else { "," }),
							"d": init(child_d),
						}))
					}
				}
				s.push(init({
					"t": init("r"),
					"v": init(if p { "[\n" + t.repeat(child_d) } else { "[" }),
					"d": init(child_d),
				}))
				continue
			}
			map[string]Type {
				dk_l := v.keys()
				if dk_l.len == 0 {
					r += "{}"
					continue
				}
				child_d := cur_d + 1
				s.push(init({
					"t": init("r"),
					"v": init(if p { "\n" + t.repeat(cur_d) + "}" } else { "}" }),
					"d": init(cur_d),
				}))
				for i := dk_l.len - 1; i >= 0; i -= 1 {
					pk := dk_l[i]
					pv := v[pk] or { None{} }
					s.push(init({
						"t": init("v"),
						"v": pv,
						"d": init(child_d),
					}))
					s.push(init({
						"t": init("r"),
						"v": init(if p { "\"" + pk + "\": " } else { "\"" + pk + "\":" }),
						"d": init(child_d),
					}))
					if i > 0 {
						s.push(init({
							"t": init("r"),
							"v": init(if p { ",\n" + t.repeat(child_d) } else { "," }),
							"d": init(child_d),
						}))
					}
				}
				s.push(init({
					"t": init("r"),
					"v": init(if p { "{\n" + t.repeat(child_d) } else { "{" }),
					"d": init(child_d),
				}))
				continue
			}
		}
	}
	return r
}
