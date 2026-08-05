class Xl {
    static iter(l) {
        return {
            "value": l,
            "current": null
        }
    }
    static next(itr) {
        var l = itr["value"]
        var cur = itr["current"]
        var nxt = l.iterate(cur)
        if (nxt == false || nxt == null) {
            Fiber.abort("StopIteration: List is empty.")
        }
        var r = l.iteratorValue(nxt)
        itr["current"] = nxt
        return r
    }
    static escapeString(s) {
        if (s == null) return ""
        var r = ""
        for (c in s.codePoints) {
            if (c == 92) { // \
                r = r + "\\\\"
            } else if (c == 34) { // "
                r = r + "\\\""
            } else if (c == 10) { // \n
                r = r + "\\n"
            } else if (c == 13) { // \r
                r = r + "\\r"
            } else if (c == 9) { // \t
                r = r + "\\t"
            } else {
                r = r + String.fromCodePoint(c)
            }
        }
        return r
    }
    static jsonStringify(va) {
        var a = va[0]
        var p = false
        if (va.count > 1 && va[1] is Map) {
            var o = va[1]
            if (o.containsKey("pretty")) {
                p = o["pretty"]
            }
        }
        var t = " " * 4
        var s = [{ "t": "v", "v": a, "d": 0 }]
        var r = ""
        while (s.count > 0) {
            var c = s.removeAt(s.count - 1)
            if (c["t"] == "r") {
                r = r + "%(c["v"])"
                continue
            }
            var v = c["v"]
            var curD = c["d"]
            if (v == null) {
                r = r + "null"
                continue
            }
            if (v is Bool) {
                r = r + (v ? "true" : "false")
                continue
            }
            if (v is String) {
                r = r + "\"" + Xl.escapeString(v) + "\""
                continue
            }
            if (v is Num) {
                r = r + "%(v)"
                continue
            }
            if (v is Fn) {
                r = r + "\"[object Function]\""
                continue
            }
            if (v is List) {
                if (v.count == 0) {
                    r = r + "[]"
                    continue
                }
                var childD = curD + 1
                s.add({
                    "t": "r",
                    "v": p ? "\n" + (t * curD) + "]" : "]",
                    "d": curD
                })
                var i = v.count - 1
                while (i >= 0) {
                    s.add({
                        "t": "v",
                        "v": v[i],
                        "d": childD
                    })
                    if (i > 0) {
                        s.add({
                            "t": "r",
                            "v": p ? ",\n" + (t * childD) : ",",
                            "d": childD
                        })
                    }
                    i = i - 1
                }
                s.add({
                    "t": "r",
                    "v": p ? "[\n" + (t * childD) : "[",
                    "d": childD
                })
                continue
            }
            if (v is Map) {
                var dpL = []
                for (pK in v.keys) {
                    dpL.add([pK, v[pK]])
                }
                if (dpL.count == 0) {
                    r = r + "{}"
                    continue
                }
                var childD = curD + 1
                s.add({
                    "t": "r",
                    "v": p ? "\n" + (t * curD) + "}" : "}",
                    "d": curD
                })
                var i = dpL.count - 1
                while (i >= 0) {
                    var pair = dpL[i]
                    var pK = pair[0]
                    var pV = pair[1]
                    s.add({
                        "t": "v",
                        "v": pV,
                        "d": childD
                    })
                    s.add({
                        "t": "r",
                        "v": p ? "\"%(pK)\": " : "\"%(pK)\":",
                        "d": childD
                    })
                    if (i > 0) {
                        s.add({
                            "t": "r",
                            "v": p ? ",\n" + (t * childD) : ",",
                            "d": childD
                        })
                    }
                    i = i - 1
                }
                s.add({
                    "t": "r",
                    "v": p ? "{\n" + (t * childD) : "{",
                    "d": childD
                })
                continue
            }
            r = r + "[object [Wren %(v)]]"
        }
        return r
    }
}
