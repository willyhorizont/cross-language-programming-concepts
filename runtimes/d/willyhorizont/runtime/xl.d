module willyhorizont.runtime.xl;

import std.variant;
import std.stdio;
import std.conv : text, to;
import std.array : replicate;
import std.range;
import std.range.interfaces;
import std.traits : ReturnType, ParameterTypeTuple;
import std.string : replace;
// import std.functional : toDelegate;
// import std.algorithm : fold, map, reduce;

struct Xl {
    Variant value;
    this(T)(T v) {
        this.value = Variant(v);
    }
    alias value this; 
    auto as(T)() {
        return unwrap!T(this);
    }
    bool toBool() {
        return unwrap!bool(this);
    }
    string toString() {
        return unwrap!string(this);
    }
    int toInt() {
        return unwrap!int(this);
    }
    double toFloat() {
        return unwrap!double(this);
    }
    Xl call(Args...)(Args args) {
        auto c = unwrap!(Lambda)(this);
        Xl[] va;
        foreach(arg; args) {
            va ~= Xl(arg);
        }
        return c(Xl(va));
    }
}

alias Lambda = Xl delegate(Xl);
alias Iterator = InputRange!Xl;

@property Xl None() {
    return Xl();
}

Xl from(T)(T v) {
    return Xl(v);
}

struct Pair {
    string key;
    Xl value;
}

Pair pair(T)(string k, T v) {
    return Pair(k, Xl(v));
}

Xl[] list(Args...)(Args args) {
    Xl[] l;
    foreach(arg; args) {
        l ~= Xl(arg);
    }
    return l;
}

Xl[string] dict(Args...)(Args args) {
    Xl[string] d;
    foreach(arg; args) {
        d[arg.key] = arg.value;
    }
    return d;
}

Xl lambda(T)(T c) {
    alias RetT = ReturnType!T;
    alias VaT = ParameterTypeTuple!T;
    static if (is(RetT == Xl) && VaT.length == 1 && is(VaT[0] == Xl)) {
        return Xl(cast(Lambda) c);
    }
    return Xl(cast(Lambda) delegate(Xl va) {
        static if (is(RetT == void)) {
            c(va);
            return None;
        } else {
            return from(c(va));
        }
    });
}

Iterator iter(Xl va) {
    if (auto lR = va.value.peek!(Xl[])) {
        return inputRangeObject(*lR);
    }
    Xl[] l = [va];
    return inputRangeObject(l);
}

Xl next(Xl v) {
    Iterator itr = unwrap!(Iterator)(v);
    Xl el = itr.front;
    itr.popFront();
    return el;
}

auto unwrap(T)(Xl a) {
    if (auto v = a.value.peek!T) return *v;
    static if (is(T == bool) || is(T == string) || is(T == int) || is(T == double)) {
        try {
            string s = a.value.to!(string);
            return s.to!(T);
        } catch(Exception e) {
            // continue
        }
    }
    static if (is(T == Xl[])) {
        if (auto l = a.value.peek!(Xl[])) return *l;
    }
    static if (is(T == Xl[string])) {
        if (auto d = a.value.peek!(Xl[string])) return *d;
    }
    static if (is(T F == delegate)) {
        alias RetT = ReturnType!T;
        alias VaT = ParameterTypeTuple!T;
        if (auto pSafe = a.value.peek!(RetT delegate(VaT) @safe)) return cast(T)*pSafe;
        if (auto pSys = a.value.peek!(RetT delegate(VaT) @system)) return cast(T)*pSys;
        if (auto pSafePure = a.value.peek!(RetT delegate(VaT) pure @safe)) return cast(T)*pSafePure;
        if (auto pSysPure = a.value.peek!(RetT delegate(VaT) pure @system)) return cast(T)*pSysPure;
        static if (is(RetT == Xl)) {
            if (auto pVoidSafe = a.value.peek!(void delegate(VaT) @safe)) {
                auto c = *pVoidSafe;
                return cast(T) delegate(VaT va) {
                    c(va);
                    return Xl();
                };
            }
            if (auto pVoidSys = a.value.peek!(void delegate(VaT) @system)) {
                auto c = *pVoidSys;
                return cast(T) delegate(VaT va) {
                    c(va);
                    return Xl();
                };
            }
        }
    }
    throw new Exception("XlRuntimeError: Failed to unwrap Xl to target type. Xl holds: " ~ a.value.type.toString());
}

string escapeString(string s) {
    string r = s;
    r = r.replace("\\", "\\\\");
    r = r.replace("\"", "\\\"");
    r = r.replace("\n", "\\n");
    r = r.replace("\r", "\\r");
    r = r.replace("\t", "\\t");
    return r;
}

string jsonStringify(Xl a, bool pretty = false) {
    struct El {
        string t;
        Xl v;
        string r;
        int d;
    }
    bool p = pretty;
    string t = " ".replicate(4);
    El[] s = [El(t: "v", v: a, r: "", d: 0)];
    string r = "";
    while (s.length > 0) {
        El c = s[$ - 1];
        s.length -= 1;
        if (c.t == "r") {
            r ~= c.r;
            continue;
        }
        Xl v = c.v;
        int curD = c.d;
        if (!v.value.hasValue) {
            r ~= "null";
            continue;
        }
        auto cT = v.value.type;
        if (cT == typeid(bool)) {
            r ~= v.toBool() ? "true" : "false";
            continue;
        }
        if (cT == typeid(string)) {
            r ~= "\"" ~ escapeString(v.toString()) ~ "\"";
            continue;
        }
        if (cT == typeid(int)) {
            r ~= v.toInt().to!(string);
            continue;
        }
        if (cT == typeid(double)) {
            r ~= v.toFloat().to!(string);
            continue;
        }
        if (v.value.peek!(Lambda)) {
            r ~= "\"[object Function]\"";
            continue;
        }
        if (auto lR = v.value.peek!(Xl[])) {
            Xl[] l = *lR;
            if (l.length == 0) {
                r ~= "[]";
                continue;
            }
            int childD = curD + 1;
            s ~= El(
                t: "r",
                v: None,
                r: p ? "\n" ~ t.replicate(curD) ~ "]" : "]",
                d: curD,
            );
            for (int i = cast(int)l.length - 1; i >= 0; i -= 1) {
                s ~= El(
                    t: "v",
                    v: l[i],
                    r: "",
                    d: childD,
                );
                if (i > 0) {
                    s ~= El(
                        t: "r",
                        v: None,
                        r: p ? ",\n" ~ t.replicate(childD) : ",",
                        d: childD,
                    );
                }
            }
            s ~= El(
                t: "r",
                v: None,
                r: p ? "[\n" ~ t.replicate(childD) : "[",
                d: childD,
            );
            continue;
        }
        if (auto dR = v.value.peek!(Xl[string])) {
            Xl[string] d = *dR;
            if (d.length == 0) {
                r ~= "{}";
                continue;
            }
            int childD = curD + 1;
            s ~= El(
                t: "r",
                v: None,
                r: p ? "\n" ~ t.replicate(curD) ~ "}" : "}",
                d: curD,
            );
            string[] pkL = d.keys;
            for (int i = cast(int)pkL.length - 1; i >= 0; i -= 1) {
                string pK = pkL[i];
                Xl pV = d[pK];
                s ~= El(
                    t: "v",
                    v: pV,
                    r: "",
                    d: childD,
                );
                s ~= El(
                    t: "r",
                    v: None,
                    r: p ? "\"" ~ pK ~ "\": " : "\"" ~ pK ~ "\":",
                    d: childD,
                );
                if (i > 0) {
                    s ~= El(
                        t: "r",
                        v: None,
                        r: p ? ",\n" ~ t.replicate(childD) : ",",
                        d: childD,
                    );
                }
            }
            s ~= El(
                t: "r",
                v: None,
                r: p ? "{\n" ~ t.replicate(childD) : "{",
                d: childD,
            );
            continue;
        }
        r ~= "\"" ~ cT.toString() ~ "\"";
    }
    return r;
}
