package willyhorizont.runtime

import std.collection.HashMap
import std.collection.ArrayList

public let NONE: Any = Option<Any>.None

public type `None` = Option<Any> // ?Any
public type `Bool` = Bool
public type `String` = String
public type Int = Int64
public type Float = Float64
public type List = ArrayList<Any>
public type Dict = HashMap<String, Any>
public type Vararg = Array<Any>
public type Closure = (Vararg) -> Any
public type `Iterator` = Iterator<Any>

public func iter(va: Vararg): `Iterator` {
    return va.iterator()
}

public func next(itr: `Iterator`): Any {
    return itr.next().getOrThrow()
}

public func call(v: Any, va: Vararg): Any {
    match (v) {
        case f: Closure => return f(va)
        case _ => throw Exception("XlRuntimeError: Expected Closure.")
    }
}

func unwrap(opt: Option<Any>): Any {
    return match (opt) {
        case Some(v) => v
        case None => Option<Any>.None
    }
}

public func asBool(v: Any): Bool {
    match (v) {
        case b: Bool => return b
        case _ => throw Exception("XlRuntimeError: Expected Bool.")
    }
}

public func asString(v: Any): String {
    match (v) {
        case s: String => return s
        case _ => throw Exception("XlRuntimeError: Expected String.")
    }
}

public func asInt(v: Any): Int {
    match (v) {
        case i: Int => return i
        case _ => throw Exception("XlRuntimeError: Expected Int.")
    }
}

public func asFloat(v: Any): Float {
    match (v) {
        case f: Float => return f
        case i: Int => return Float64(i)
        case _ => throw Exception("XlRuntimeError: Expected Float.")
    }
}

public func repeat(s: String, x: Int): String {
    if (x <= 0) { return "" }
    let r = StringBuilder()
    for (_ in 0..x) {
        r.append(s)
    }
    return r.toString()
}

func escapeString(s: String): String {
    let r = StringBuilder()
    for (c in s.toRuneArray()) {
        match (c) {
            case r'\\' => r.append("\\\\")
            case r'"' => r.append("\\\"")
            case r'\n' => r.append("\\n")
            case r'\r' => r.append("\\r")
            case r'\t' => r.append("\\t")
            case _ => r.append(c)
        }
    }
    return r.toString()
}

public func jsonStringify(a: Any, pretty!: Bool = false): String {
    let p = pretty
    let t = repeat(" ", 4)
    let s = ArrayList<Dict>([Dict([("t", "v"), ("v", a), ("d", 0)])])
    let r = StringBuilder()
    while (s.size > 0) {
        let curI = s.size - 1
        let c = s.get(curI).getOrThrow()
        s.remove(at: curI)
        if (asString(unwrap(c.get("t"))) == "r") {
            r.append(asString(unwrap(c.get("v"))))
            continue
        }
        let curD = asInt(unwrap(c.get("d")))
        let v = unwrap(c.get("v"))
        match (v) {
            case optV: Option<Any> =>
                match (optV) {
                    case None => r.append("null")
                    case Some(innerV) => s.add(Dict([("t", "v"), ("v", innerV), ("d", curD)]))
                }
            case bV: Bool =>
                r.append(if (bV) { "true" } else { "false" })
            case sV: String =>
                r.append("\"" + escapeString(sV) + "\"")
            case iV: Int64 =>
                r.append(iV.toString())
            case fV: Float64 =>
                r.append(fV.toString())
            case lV: List =>
                if (lV.size == 0) {
                    r.append("[]")
                    continue
                }
                let childD = curD + 1
                s.add(Dict([
                    ("t", "r"),
                    ("v", if (p) { "\n" + repeat(t, curD) + "]" } else { "]" }),
                    ("d", curD),
                ]))
                var i = lV.size - 1
                while (i >= 0) {
                    s.add(Dict([
                        ("t", "v"),
                        ("v", unwrap(lV.get(i))),
                        ("d", childD),
                    ]))
                    if (i > 0) {
                        s.add(Dict([
                            ("t", "r"),
                            ("v", if (p) { ",\n" + repeat(t, childD) } else { "," }),
                            ("d", childD),
                        ]))
                    }
                    i -= 1
                }
                s.add(Dict([
                    ("t", "r"),
                    ("v", if (p) { "[\n" + repeat(t, childD) } else { "[" }),
                    ("d", childD),
                ]))
            case dV: Dict =>
                if (dV.size == 0) {
                    r.append("{}")
                    continue
                }
                let childD = curD + 1
                s.add(Dict([
                    ("t", "r"),
                    ("v", if (p) { "\n" + repeat(t, curD) + "}" } else { "}" }),
                    ("d", curD),
                ]))
                let dpl = ArrayList<( String, Any )>()
                for ((pk, pv) in dV) {
                    dpl.add((pk, pv))
                }
                var i = dpl.size - 1
                while (i >= 0) {
                    let (pK, pV) = dpl.get(i).getOrThrow()
                    s.add(Dict([
                        ("t", "v"),
                        ("v", pV),
                        ("d", childD),
                    ]))
                    s.add(Dict([
                        ("t", "r"),
                        ("v", if (p) { "\"" + pK + "\": " } else { "\"" + pK + "\":" }),
                        ("d", childD),
                    ]))
                    if (i > 0) {
                        s.add(Dict([
                            ("t", "r"),
                            ("v", if (p) { ",\n" + repeat(t, childD) } else { "," }),
                            ("d", childD),
                        ]))
                    }
                    i -= 1
                }
                s.add(Dict([
                    ("t", "r"),
                    ("v", if (p) { "{\n" + repeat(t, childD) } else { "{" }),
                    ("d", childD),
                ]))
            case _ =>
                if (v is Closure) {
                    r.append("\"[object Function]\"")
                } else {
                    r.append("\"[object Cangjie]\"")
                }
        }
    }
    return r.toString()
}
