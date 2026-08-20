package runtimes.kotlin.willyhorizont.runtime

object xl {
    fun toBool(a: Any?): Boolean {
        return when (a) {
            is Boolean -> a
            else -> throw RuntimeException("XlRuntimeError: Expected Bool.")
        }
    }
    fun toString(a: Any?): String {
        return when (a) {
            null -> "null"
            is String -> a
            else -> throw RuntimeException("XlRuntimeError: Expected String.")
        }
    }
    fun toInt(a: Any?): Long {
        return when (a) {
            is Number -> a.toLong()
            else -> throw RuntimeException("XlRuntimeError: Expected Int.")
        }
    }
    fun toFloat(a: Any?): Double {
        return when (a) {
            is Number -> a.toDouble()
            else -> throw RuntimeException("XlRuntimeError: Expected Float.")
        }
    }
    fun initList(vararg va: Any?): ArrayList<Any?> {
        val l = ArrayList<Any?>()
        l.addAll(va)
        return l
    }
    fun initDict(vararg dpl: Pair<String, Any?>): HashMap<String, Any?> {
        val d = HashMap<String, Any?>()
        for (p in dpl) {
            d[p.first] = p.second
        }
        return d
    }
    fun iter(va: Any?): Iterator<Any?> {
        return when (va) {
            is List<*> -> va.iterator()
            is Array<*> -> va.iterator()
            else -> throw RuntimeException("XlRuntimeError: Expected List.")
        }
    }
    fun next(itr: Any?): Any? {
        if (itr is Iterator<*>) {
            return if (itr.hasNext()) itr.next() else null
        }
        throw RuntimeException("XlRuntimeError: Expected Iterator.")
    }
    @Suppress("UNCHECKED_CAST")
    fun call(lambda: Any?, vararg a: Any?): Any? {
        if (lambda is Function1<*, *>) {
            val va = arrayListOf<Any?>()
            va.addAll(a)
            return (lambda as Function1<Any?, Any?>)(va)
        }
        throw RuntimeException("XlRuntimeError: Expected Lambda.")
    }
    fun escapeString(s: Any?): String {
        if (s == null) return ""
        return s.toString()
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t")
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
            if (v is Function1<*, *>) {
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
