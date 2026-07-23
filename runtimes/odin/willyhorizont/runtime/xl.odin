package xl
import "core:fmt"
import "core:strings"

Bool :: bool
String :: string
Int :: int
Float :: f64
List :: [dynamic]Type
Dict :: map[String]Type
Pair :: struct { key: String, value: Type }
Lambda :: struct {
	value: rawptr,
	call: proc(self: ^Lambda, varargs: ..Type) -> Type,
}

Type :: union {
    Bool,
    String,
    Int,
    Float,
    List,
    Dict,
    Lambda,
}

Iterator :: struct {
    args: []Type,
    idx:  int,
}

iter :: proc(varargs: ..Type) -> Iterator {
    return Iterator{ args = varargs, idx = 0 }
}

next :: proc(it: ^Iterator) -> Type {
    if it.idx >= len(it.args) {
        return nil
    }
    v := it.args[it.idx]
    it.idx += 1
    return v
}

Scope :: struct {
    outer: ^Scope,
    var: Dict,
}

reg_scope :: proc(outer: ^Scope = nil, initial_vars: ..Dict) -> ^Scope {
    s := new(Scope)
    s.outer = outer
    s.var = make(Dict)
    if len(initial_vars) > 0 {
        for k, v in initial_vars[0] {
            s.var[k] = v
        }
    }
    return s
}

get_var :: proc(s: ^Scope, name: String) -> Type {
    c := s
    for c != nil {
        if v, ok := c.var[name]; ok {
            return v
        }
        c = c.outer
    }
    return nil
}

set_var :: proc(s: ^Scope, name: String, value: Type) -> Bool {
    c := s
    for c != nil {
        if _, ok := c.var[name]; ok {
            c.var[name] = value
            return true
        }
        c = c.outer
    }
    s.var[name] = value
    return false
}

unreg_scope :: proc(s: ^Scope) {
    if s == nil do return
    delete(s.var)
    free(s)
}

string_repeat :: proc(a: String, n: Int) -> String {
    s := strings.builder_make(context.temp_allocator)
    for _ in 0..<n {
        strings.write_string(&s, string(a))
    }
    return strings.to_string(s)
}

escape_string :: proc(sb: ^strings.Builder, s: string) {
	if len(s) == 0 do return
	for char in s {
		switch char {
		case '\\':
            strings.write_string(sb, "\\\\")
		case '"':
            strings.write_string(sb, "\\\"")
		case '\n':
            strings.write_string(sb, "\\n")
		case '\r':
            strings.write_string(sb, "\\r")
		case '\t':
            strings.write_string(sb, "\\t")
		case:
            strings.write_rune(sb, char)
		}
	}
}

json_stringify :: proc(a: Type, o: struct { pretty: Bool } = {}) -> String {
    pretty := o.pretty
    if a == nil do return "null"
    t := string_repeat(" ", 4)
    JifyStkEl :: struct {
        t: String,
        v: Type,
        r: String,
        d: Int,
    }
    s: [dynamic]JifyStkEl = make([dynamic]JifyStkEl, context.temp_allocator)
    append(&s, JifyStkEl{t = "v", v = a, r = "", d = 0})
    r := strings.builder_make()
    for len(s) > 0 {
        c := pop(&s)
        if c.t == "r" {
            strings.write_string(&r, c.r)
            continue
        }
        v := c.v
        cur_d := c.d
        if v == nil {
            strings.write_string(&r, "null")
            continue
        }
        if bv, ok := v.(Bool); ok {
            strings.write_string(&r, bv ? "true" : "false")
            continue
        }
        if sv, ok := v.(String); ok {
            strings.write_string(&r, "\"")
            escape_string(&r, sv)
            strings.write_string(&r, "\"")
            continue
        }
        if iv, ok := v.(Int); ok {
            fmt.sbprint(&r, iv)
            continue
        }
        if fv, ok := v.(Float); ok {
            fmt.sbprint(&r, fv)
            continue
        }
        if _, ok := v.(Lambda); ok {
            strings.write_string(&r, "\"[object Function]\"")
            continue
        }
        if lv, ok := v.(List); ok {
            if len(lv) == 0 {
                strings.write_string(&r, "[]")
                continue
            }
            child_d := cur_d + 1
            append(&s, JifyStkEl{
                t = "r",
                v = nil,
                r = pretty ? strings.concatenate({"\n", string_repeat(t, cur_d), "]"}, context.temp_allocator) : "]",
                d = cur_d,
            })
            for i := len(lv) - 1; i >= 0; i -= 1 {
                append(&s, JifyStkEl{
                    t = "v",
                    v = lv[i],
                    r = "",
                    d = child_d,
                })
                if i > 0 {
                    append(&s, JifyStkEl{
                        t = "r",
                        v = nil,
                        r = pretty ? strings.concatenate({",\n", string_repeat(t, child_d)}, context.temp_allocator) : ",",
                        d = child_d,
                    })
                }
            }
            append(&s, JifyStkEl{
                t = "r",
                v = nil,
                r = pretty ? strings.concatenate({"[\n", string_repeat(t, child_d)}, context.temp_allocator) : "[",
                d = child_d,
            })
            continue
        }
        if dv, ok := v.(Dict); ok {
            if len(dv) == 0 {
                strings.write_string(&r, "{}")
                continue
            }
            child_d := cur_d + 1
            append(&s, JifyStkEl{
                t = "r",
                v = nil,
                r = pretty ? strings.concatenate({"\n", string_repeat(t, cur_d), "}"}, context.temp_allocator) : "}",
                d = cur_d,
            })
            dpl := make([dynamic]Pair, context.temp_allocator)
            for dpk, dpv in dv {
                append(&dpl, Pair{key = dpk, value = dpv})
            }
            for i := len(dpl) - 1; i >= 0; i -= 1 {
                dp := dpl[i]
                append(&s, JifyStkEl{
                    t = "v",
                    v = dp.value,
                    r = "",
                    d = child_d
                })
                append(&s, JifyStkEl{
                    t = "r",
                    v = nil,
                    r = pretty ? fmt.tprintf("\"%s\": ", dp.key) : fmt.tprintf("\"%s\":", dp.key),
                    d = child_d
                })
                if i > 0 {
                    append(&s, JifyStkEl{
                        t = "r",
                        v = nil,
                        r = pretty ? strings.concatenate({",\n", string_repeat(t, child_d)}, context.temp_allocator) : ",",
                        d = child_d
                    })
                }
            }
            append(&s, JifyStkEl{
                t = "r",
                v = nil,
                r = pretty ? strings.concatenate({"{\n", string_repeat(t, child_d)}, context.temp_allocator) : "{",
                d = child_d
            })
            continue
        }
        strings.write_string(&r, "\"[object \\\"Odin Object\\\"]\"")
    }
    return strings.to_string(r)
}
