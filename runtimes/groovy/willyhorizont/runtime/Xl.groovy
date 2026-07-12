package runtimes.groovy.willyhorizont.runtime

import groovy.json.JsonOutput

class Xl {
    static String jsonStringify(Object a, Map op = [:]) {
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
