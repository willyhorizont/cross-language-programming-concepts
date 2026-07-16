package runtimes.kotlin.willyhorizont.runtime

object xl {
    interface Closure {
        fun call(va: Array<out Any?>): Any?
        operator fun invoke(vararg args: Any?): Any? {
            return call(args)
        }
    }
    
    fun escapeString(s: Any?): String {
        if (s == null) return ""
        var r = s.toString()
        r = r.replace("\\", "\\\\")
        r = r.replace("\"", "\\\"")
        r = r.replace("\n", "\\n")
        r = r.replace("\r", "\\r")
        r = r.replace("\t", "\\t")
        return r
    }
    
    fun jsonStringify(a: Any?, pretty: Boolean = false): String {
        val p = pretty
        val t = " ".repeat(4)
        val s = arrayListOf<HashMap<String, Any?>>(hashMapOf("t" to "v", "v" to a, "d" to 0))
        var r = ""
        while (s.isNotEmpty()) {
            val c = s.removeAt(s.size - 1)
            if (c["t"] == "r") {
                r += c["v"].toString()
                continue
            }
            val v = c["v"]
            val curD = c["d"] as Int
            if (v == null) {
                r += "null"
                continue
            }
            if (v is Boolean) {
                r += if (v) "true" else "false"
                continue
            }
            if (v is String) {
                r += "\"" + escapeString(v) + "\""
                continue
            }
            if (v is Number) {
                r += v.toString()
                continue
            }
            if (v is Closure) {
                r += "\"[object Function]\""
                continue
            }
            if (v is List<*>) {
                if (v.isEmpty()) {
                    r += "[]"
                    continue
                }
                val childD = curD + 1
                s.add(hashMapOf(
                    "t" to "r",
                    "v" to if (p) "\n" + t.repeat(curD) + "]" else "]",
                    "d" to curD,
                ))
                for (i in v.size - 1 downTo 0) {
                    s.add(hashMapOf(
                        "t" to "v",
                        "v" to v[i],
                        "d" to childD,
                    ))
                    if (i > 0) {
                        s.add(hashMapOf(
                            "t" to "r",
                            "v" to if (p) ",\n" + t.repeat(childD) else ",",
                            "d" to childD,
                        ))
                    }
                }
                s.add(hashMapOf(
                    "t" to "r",
                    "v" to if (p) "[\n" + t.repeat(childD) else "[",
                    "d" to childD,
                ))
                continue
            }
            if (v is Map<*, *>) {
                val dpL = v.entries.toList()
                if (dpL.isEmpty()) {
                    r += "{}"
                    continue
                }
                val childD = curD + 1
                s.add(hashMapOf(
                    "t" to "r",
                    "v" to if (p) "\n" + t.repeat(curD) + "}" else "}",
                    "d" to curD,
                ))
                for (i in dpL.size - 1 downTo 0) {
                    val dK = dpL[i].key
                    val dV = dpL[i].value
                    s.add(hashMapOf(
                        "t" to "v",
                        "v" to dV,
                        "d" to childD,
                    ))
                    s.add(hashMapOf(
                        "t" to "r",
                        "v" to if (p) "\"" + dK.toString() + "\": " else "\"" + dK.toString() + "\":",
                        "d" to childD,
                    ))
                    if (i > 0) {
                        s.add(hashMapOf(
                            "t" to "r",
                            "v" to if (p) ",\n" + t.repeat(childD) else ",",
                            "d" to childD,
                        ))
                    }
                }
                s.add(hashMapOf(
                    "t" to "r",
                    "v" to if (p) "{\n" + t.repeat(childD) else "{",
                    "d" to childD,
                ))
                continue
            }
            r += "\"" + v::class.java.simpleName + "\""
        }
        return r
    }
}
