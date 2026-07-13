package runtimes.groovy.willyhorizont.runtime

import groovy.json.JsonOutput

class Xl {
    public static escapeString(s) {
        if (s == null) return ""
        return s.replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t")
    }
    public static jsonStringify(a, op = [:]) {
        def p = op.containsKey("pretty") ? op["pretty"] == true : false
        def t = " ".multiply(4)
        def s = [["t": "v", "v": a, "d": 0]]
        def r = ""
        while (!s.isEmpty()) {
            def c = s.removeAt(s.size() - 1)
            if (c["t"] == "r") {
                r += c["v"]
                continue
            }
            Object v = c["v"]
            def curD = (int) c["d"]
            if (v == null) {
                r += "null"
                continue
            }
            if (v instanceof Boolean) {
                r += v ? "true" : "false"
                continue
            }
            if (v instanceof CharSequence || v instanceof Character) {
                r += "\"" + escapeString(v.toString()) + "\""
                continue
            }
            if (v instanceof Number) {
                r += v.toString()
                continue
            }
            if (v instanceof Closure) {
                r += "\"[object Function]\""
                continue
            }
            if (v instanceof List || v.getClass().isArray()) {
                if (v.isEmpty()) {
                    r += "[]"
                    continue
                }
                def childD = curD + 1
                s.add([
                    "t": "r",
                    "v": p ? "\n" + t.multiply(curD) + "]" : "]",
                    "d": curD
                ])
                for (def i = v.size() - 1; i >= 0; i -= 1) {
                    s.add([
                        "t": "v",
                        "v": v[i],
                        "d": childD
                    ])
                    if (i > 0) {
                        s.add([
                            "t": "r",
                            "v": p ? ",\n" + t.multiply(childD) : ",",
                            "d": childD
                        ])
                    }
                }
                s.add([
                    "t": "r",
                    "v": p ? "[\n" + t.multiply(childD) : "[",
                    "d": childD
                ])
                continue
            }
            if (v instanceof Map) {
                if (v.isEmpty()) {
                    r += "{}"
                    continue
                }
                def childD = curD + 1
                s.add([
                    "t": "r",
                    "v": p ? "\n" + t.multiply(curD) + "}" : "}",
                    "d": curD
                ])
                def dpL = v.collect { dk, dv -> [k: dk, val: dv] }
                for (def i = dpL.size() - 1; i >= 0; i -= 1) {
                    def dplEl = dpL[i]
                    s.add([
                        "t": "v",
                        "v": dplEl.val,
                        "d": childD
                    ])
                    s.add([
                        "t": "r",
                        "v": p ? "\"" + dplEl.k.toString() + "\": " : "\"" + dplEl.k.toString() + "\":",
                        "d": childD
                    ])
                    if (i > 0) {
                        s.add([
                            "t": "r",
                            "v": p ? ",\n" + t.multiply(childD) : ",",
                            "d": childD
                        ])
                    }
                }
                s.add([
                    "t": "r",
                    "v": p ? "{\n" + t.multiply(childD) : "{",
                    "d": childD
                ])
                continue
            }
            r += "\"" + v.getClass().getSimpleName() + "\""
        }
        return r
    }
    public static stdJsonStringify(a, op = [:]) {
        def r = ["v": a]
        def s = [["t": r, "k": "v", "v": a]]
        while (!s.isEmpty()) {
            def c = s.removeAt(s.size() - 1)
            def t = c["t"]
            def k = c["k"]
            def v = c["v"]
            if (v instanceof Closure) {
                t[k] = "[object Function]"
                continue
            }
            if (v instanceof List) {
                def nL = []
                t[k] = nL
                v.reverseEach { lEl ->
                    s.add(["t": nL, "k": v.indexOf(lEl), "v": lEl])
                }
                continue
            }
            if (v instanceof Map) {
                def nD = [:]
                t[k] = nD
                v.collect { pK, pV -> ["pK": pK, "pV": pV] }.reverseEach { p ->
                    s.add(["t": nD, "k": p["pK"], "v": p["pV"]])
                }
                continue
            }
            t[k] = v
        }
        def jifyS = JsonOutput.toJson(r["v"])
        return op["pretty"] == true ? JsonOutput.prettyPrint(jifyS) : jifyS
    }
}
