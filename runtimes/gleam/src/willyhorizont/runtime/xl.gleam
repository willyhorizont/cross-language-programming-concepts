import gleam/dict
import gleam/list
import gleam/string
import gleam/int
import gleam/float

pub type Xl {
    None
    Bool(Bool)
    String(String)
    Int(Int)
    Float(Float)
    List(List(Xl))
    Dict(dict.Dict(String, Xl))
    Lambda(fn(List(Xl)) -> Xl)
}

pub fn call(c: Xl, va: List(Xl)) -> Xl {
    case c {
        Lambda(f) -> f(va)
        _ -> panic as "Error: Invalid arguments."
    }
}

pub const none = None
// pub fn none() -> Xl { None }
pub fn bool(b: Bool) -> Xl { Bool(b) }
pub fn string(s: String) -> Xl { String(s) }
pub fn int(n: Int) -> Xl { Int(n) }
pub fn float(f: Float) -> Xl { Float(f) }
pub fn list(l: List(Xl)) -> Xl { List(l) }
pub fn dict(p: List(#(String, Xl))) -> Xl { Dict(dict.from_list(p)) }
pub fn lambda(f: fn(List(Xl)) -> Xl) -> Xl { Lambda(f) }

pub fn to_bool(v: Xl) -> Bool {
    case v {
        None -> False
        Bool(b) -> b
        String("") -> False
        String(_) -> True
        Int(0) -> False
        Int(_) -> True
        Float(0.0) -> False
        Float(_) -> True
        List([]) -> False
        List(_) -> True
        Dict(d) -> dict.size(d) > 0
        Lambda(_) -> True
    }
}

pub fn to_string(v: Xl) -> String {
    case v {
        None -> "null"
        Bool(True) -> "true"
        Bool(False) -> "false"
        String(s) -> s
        Int(v) -> int.to_string(v)
        Float(v) -> float.to_string(v)
        List(v) -> string.inspect(v)
        Dict(v) -> string.inspect(v)
        Lambda(v) -> string.inspect(v)
    }
}

pub fn to_int(v: Xl) -> Int {
    case v {
        String(s) -> {
            case int.parse(s) {
                Ok(n) -> n
                Error(_) -> 0
            }
        }
        Int(n) -> n
        Float(f) -> float.round(f)
        _ -> panic as "Error: Invalid arguments."
    }
}

pub fn to_float(v: Xl) -> Float {
    case v {
        String(s) -> {
            case float.parse(s) {
                Ok(f) -> f
                Error(_) -> 0.0
            }
        }
        Int(n) -> int.to_float(n)
        Float(f) -> f
        _ -> panic as "Error: Invalid arguments."
    }
}

pub fn to_list(v: Xl) -> List(Xl) {
    case v {
        None -> []
        List(l) -> l
        _ -> panic as "Error: Invalid arguments."
    }
}

pub fn to_dict(v: Xl) -> dict.Dict(String, Xl) {
    case v {
        Dict(d) -> d
        _ -> panic as "Error: Invalid arguments."
    }
}

pub fn to_lambda(v: Xl) -> fn(List(Xl)) -> Xl {
    case v {
        Lambda(f) -> f
        _ -> panic as "Error: Invalid arguments."
    }
}

pub fn at(l: List(Xl), i: Int) -> Xl {
    case l {
        [] -> None
        [h, .._] if i == 0 -> h
        [_, ..t] if i > 0 -> at(t, i - 1)
        _ -> panic as "Error: Invalid arguments."
    }
}

pub fn escape_string(s: String) -> String {
    case s {
        "" -> ""
        _ -> {
            s
            |> string.replace(each: "\\", with: "\\\\")
            |> string.replace(each: "\"", with: "\\\"")
            |> string.replace(each: "\n", with: "\\n")
            |> string.replace(each: "\r", with: "\\r")
            |> string.replace(each: "\t", with: "\\t")
        }
    }
}

type JifyStkEl {
    JifyStkElR(v: String)
    JifyStkElV(v: Xl, d: Int)
}

fn jify_list(
    l: List(Xl),
    child_d: Int,
    p: Bool,
    t: String,
    acc_stk: List(JifyStkEl),
) -> List(JifyStkEl) {
    case l {
        [] -> acc_stk
        [head, ..tail] -> {
            let next_acc = [JifyStkElV(head, child_d), ..acc_stk]
            let next_acc_p = case tail {
                [] -> next_acc
                _ -> {
                    let slelsep = case p {
                        True -> ",\n" <> string.repeat(t, child_d)
                        False -> ","
                    }
                    [JifyStkElR(slelsep), ..next_acc]
                }
            }
            jify_list(tail, child_d, p, t, next_acc_p)
        }
    }
}

fn jify_dict(
    dpl: List(#(String, Xl)),
    child_d: Int,
    p: Bool,
    t: String,
    acc_stk: List(JifyStkEl),
) -> List(JifyStkEl) {
    case dpl {
        [] -> acc_stk
        [#(k, v), ..tail] -> {
            let sdkp = case p {
                True -> "\"" <> k <> "\": "
                False -> "\"" <> k <> "\":"
            }
            let next_acc = [JifyStkElR(sdkp), JifyStkElV(v, child_d), ..acc_stk]
            let next_acc_p = case tail {
                [] -> next_acc
                _ -> {
                    let sdelsep = case p {
                        True -> ",\n" <> string.repeat(t, child_d)
                        False -> ","
                    }
                    [JifyStkElR(sdelsep), ..next_acc]
                }
            }
            jify_dict(tail, child_d, p, t, next_acc_p)
        }
    }
}

fn jify_loop(s: List(JifyStkEl), r: String, p: Bool) -> String {
    case s {
        [] -> r
        [JifyStkElR(v), ..ns] -> {
            jify_loop(ns, r <> v, p)
        }
        [JifyStkElV(v, cur_d), ..ns] -> {
            let t = string.repeat(" ", 4)
            let child_d = cur_d + 1
            case v {
                None -> jify_loop(ns, r <> "null", p)
                Bool(True) -> jify_loop(ns, r <> "true", p)
                Bool(False) -> jify_loop(ns, r <> "false", p)
                String(sv) -> jify_loop(ns, r <> "\"" <> escape_string(sv) <> "\"", p)
                Int(iv) -> jify_loop(ns, r <> int.to_string(iv), p)
                Float(fv) -> jify_loop(ns, r <> float.to_string(fv), p)
                Lambda(_) -> jify_loop(ns, r <> "\"[object Function]\"", p)
                List(lv) -> {
                    case lv {
                        [] -> jify_loop(ns, r <> "[]", p)
                        _ -> {
                            jify_loop([JifyStkElR(case p {
                                True -> "[\n" <> string.repeat(t, child_d)
                                False -> "["
                            }), ..jify_list(list.reverse(lv), child_d, p, t, [JifyStkElR(case p {
                                True -> "\n" <> string.repeat(t, cur_d) <> "]"
                                False -> "]"
                            }), ..ns])], r, p)
                        }
                    }
                }
                Dict(dv) -> {
                    let dpl = dict.to_list(dv)
                    case dpl {
                        [] -> jify_loop(ns, r <> "{}", p)
                        _ -> {
                            jify_loop([JifyStkElR(case p {
                                True -> "{\n" <> string.repeat(t, child_d)
                                False -> "{"
                            }), ..jify_dict(list.reverse(dpl), child_d, p, t, [JifyStkElR(case p {
                                True -> "\n" <> string.repeat(t, cur_d) <> "}"
                                False -> "}"
                            }), ..ns])], r, p)
                        }
                    }
                }
            }
        }
    }
}

pub fn json_stringify(a: List(Xl)) -> String {
    let #(x, o) = case a {
        [fa, sa, ..] -> #(fa, sa)
        [fa] -> #(fa, None)
        [] -> #(None, None)
    }
    let p = case o {
        Dict(d) -> {
            case dict.get(d, "pretty") {
                Ok(v) -> to_bool(v)
                Error(_) -> False
            }
        }
        _ -> False
    }
    let s = [JifyStkElV(x, 0)]
    jify_loop(s, "", p)
}
