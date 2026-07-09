import gleam/dict
import gleam/float
import gleam/int
import gleam/string

pub type Xl {
    None
    Bool(Bool)
    String(String)
    Int(Int)
    Float(Float)
    List(List(Xl))
    Dict(dict.Dict(String, Xl))
    Closure(fn(List(Xl)) -> Xl)
}

pub fn call(c: Xl, va: List(Xl)) -> Xl {
    case c {
        Closure(f) -> f(va)
        _ -> None
    }
}

pub fn none() -> Xl {
    None
}

pub fn bool(b: Bool) -> Xl {
    Bool(b)
}

pub fn string(s: String) -> Xl {
    String(s)
}

pub fn int(n: Int) -> Xl {
    Int(n)
}

pub fn float(f: Float) -> Xl {
    Float(f)
}

pub fn list(l: List(Xl)) -> Xl {
    List(l)
}

pub fn dict(p: List(#(String, Xl))) -> Xl {
    Dict(dict.from_list(p))
}

pub fn closure(f: fn(List(Xl)) -> Xl) -> Xl {
    Closure(f)
}

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
        Closure(_) -> True
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
        Closure(v) -> string.inspect(v)
    }
}

pub fn to_int(v: Xl) -> Int {
    case v {
        None -> 0
        Bool(True) -> 1
        Bool(False) -> 0
        String(s) -> {
            case int.parse(s) {
                Ok(n) -> n
                Error(_) -> 0
            }
        }
        Int(n) -> n
        Float(f) -> float.round(f)
        List(_) -> 0
        Dict(_) -> 0
        Closure(_) -> 0
    }
}

pub fn to_float(v: Xl) -> Float {
    case v {
        None -> 0.0
        Bool(True) -> 1.0
        Bool(False) -> 0.0
        String(s) -> {
            case float.parse(s) {
                Ok(f) -> f
                Error(_) -> 0.0
            }
        }
        Int(n) -> int.to_float(n)
        Float(f) -> f
        List(_) -> 0.0
        Dict(_) -> 0.0
        Closure(_) -> 0.0
    }
}

pub fn to_list(v: Xl) -> List(Xl) {
    case v {
        None -> []
        List(l) -> l
        _ -> [v]
    }
}

pub fn to_dict(v: Xl) -> dict.Dict(String, Xl) {
    case v {
        Dict(d) -> d
        _ -> dict.new()
    }
}

pub fn to_closure(v: Xl) -> fn(List(Xl)) -> Xl {
    case v {
        Closure(f) -> f
        _ -> fn(_) { None }
    }
}

pub fn at(l: List(Xl), i: Int) -> Xl {
    case l {
        [] -> None
        [h, .._] if i == 0 -> h
        [_, ..t] if i > 0 -> at(t, i - 1)
        _ -> None
    }
}

type StkEl {
    Raw(v: String)
    Val(v: Xl, d: Int)
}

pub fn json_stringify(a: Xl) -> String {
    let #(x, o) = case a {
        List([fa, sa, ..]) -> #(fa, sa)
        List([fa]) -> #(fa, None)
        _ -> #(a, None)
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
    let s = [Val(x, 0)]
    jify_loop(s, "", p)
}

fn jify_loop(s: List(StkEl), r: String, p: Bool) -> String {
    case s {
        [] -> r
        [Raw(v), ..ns] -> {
            jify_loop(ns, r <> v, p)
        }
        [Val(v, cur_d), ..ns] -> {
            let t = string.repeat(" ", 4)
            let child_d = cur_d + 1
            case v {
                None -> jify_loop(ns, r <> "null", p)
                Bool(True) -> jify_loop(ns, r <> "true", p)
                Bool(False) -> jify_loop(ns, r <> "false", p)
                String(sv) -> jify_loop(ns, r <> "\"" <> sv <> "\"", p)
                Int(iv) -> jify_loop(ns, r <> int.to_string(iv), p)
                Float(fv) -> jify_loop(ns, r <> float.to_string(fv), p)
                Closure(_) -> jify_loop(ns, r <> "\"[object Function]\"", p)
                List(lv) -> {
                    case lv {
                        [] -> jify_loop(ns, r <> "[]", p)
                        _ -> {
                            let slcb = case p {
                                True -> "\n" <> string.repeat(t, cur_d) <> "]"
                                False -> "]"
                            }
                            let slcbp = [Raw(slcb), ..ns]
                            let slel = jify_list(lv, child_d, p, t, slcbp)
                            let slob = case p {
                                True -> "[\n" <> string.repeat(t, child_d)
                                False -> "["
                            }
                            jify_loop([Raw(slob), ..slel], r, p)
                        }
                    }
                }
                Dict(dv) -> {
                    let dpl = dict.to_list(dv)
                    case dpl {
                        [] -> jify_loop(ns, r <> "{}", p)
                        _ -> {
                            let sdcb = case p {
                                True -> "\n" <> string.repeat(t, cur_d) <> "}"
                                False -> "}"
                            }
                            let sdcbp = [Raw(sdcb), ..ns]
                            let sdel = jify_dict(dpl, child_d, p, t, sdcbp)
                            let sdob = case p {
                                True -> "{\n" <> string.repeat(t, child_d)
                                False -> "{"
                            }
                            jify_loop([Raw(sdob), ..sdel], r, p)
                        }
                    }
                }
            }
        }
    }
}

fn jify_list(
    l: List(Xl),
    child_d: Int,
    p: Bool,
    t: String,
    acc_stk: List(StkEl),
) -> List(StkEl) {
    case l {
        [] -> acc_stk
        [head, ..tail] -> {
            let next_acc = [Val(head, child_d), ..acc_stk]
            let next_acc_p = case tail {
                [] -> next_acc
                _ -> {
                    let slelsep = case p {
                        True -> ",\n" <> string.repeat(t, child_d)
                        False -> ","
                    }
                    [Raw(slelsep), ..next_acc]
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
    acc_stk: List(StkEl),
) -> List(StkEl) {
    case dpl {
        [] -> acc_stk
        [#(k, v), ..tail] -> {
            let sdkp = case p {
                True -> "\"" <> k <> "\": "
                False -> "\"" <> k <> "\":"
            }
            let next_acc = [Raw(sdkp), Val(v, child_d), ..acc_stk]
            let next_acc_p = case tail {
                [] -> next_acc
                _ -> {
                    let sdelsep = case p {
                        True -> ",\n" <> string.repeat(t, child_d)
                        False -> ","
                    }
                    [Raw(sdelsep), ..next_acc]
                }
            }
            jify_dict(tail, child_d, p, t, next_acc_p)
        }
    }
}
