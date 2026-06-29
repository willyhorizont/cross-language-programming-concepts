package runtimes.groovy.willyhorizont

import groovy.json.JsonOutput

class Runtime {
    static jsonStringify(r, op = [:]) {
        def t = [value: r]
        def s = []
        s.add([holder: t, key: "value", data: r])

        while (!s.isEmpty()) {
            def c = s.removeAt(s.size() - 1)
            def h = c["holder"]
            def ky = c["key"]
            def d = c["data"]

            if (d instanceof Closure) {
                h[ky] = "[object XlClosure]"
            } else if (d instanceof List) {
                def nL = []
                h[ky] = nL

                for (int i = d.size() - 1; i >= 0; i--) {
                    s.add([holder: nL, key: i, data: d[i]])
                }
            } else if (d instanceof Map) {
                def nD = [:]
                h[ky] = nD

                def dIs = d.collect { k, v -> [key: k, val: v] }
                for (int i = dIs.size() - 1; i >= 0; i--) {
                    def dI = dIs[i]
                    s.add([holder: nD, key: dI["key"], data: dI.val])
                }
            } else {
                h[ky] = d
            }
        }

        def jS = JsonOutput.toJson(t.value)
        if (op["pretty"] == true) return JsonOutput.prettyPrint(jS)
        return jS
    }
}
