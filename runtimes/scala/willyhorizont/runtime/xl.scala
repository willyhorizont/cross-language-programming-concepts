package willyhorizont.runtime

import scala.collection.mutable.{Map => MutableMap, ArrayBuffer}

object Xl {
    def initList(ell: Any*): Any = {
        val l = ArrayBuffer[Any]()
        ell.foreach((el) => {
            l.append(el)
        })
        return l
    }

    def initDict(pairs: (String, Any)*): Any = {
        val d = MutableMap[String, Any]()
        pairs.foreach { case (k, v) =>
            d.put(k, v)
        }
        return d
    }

    def escapeString(s: String): String = {
        if (s == null) return ""
        var r = s
        r = r.replace("\\", "\\\\")
        r = r.replace("\"", "\\\"")
        r = r.replace("\n", "\\n")
        r = r.replace("\r", "\\r")
        r = r.replace("\t", "\\t")
        return r
    }

    def jsonStringify(a: Any, pretty: Boolean = false): String = {
        val p = pretty
        val t = " ".repeat(4)
        val s = initList(initDict("t"-> "v", "v"-> a, "d"-> 0)).asInstanceOf[ArrayBuffer[Any]]
        var r = ""
        while (s.length > 0) {
            val c = s.remove(s.length - 1).asInstanceOf[MutableMap[String, Any]]
            if (c("t") == "r") {
                r += c("v").toString
            } else {
                val v = c("v")
                val curD = c("d").asInstanceOf[Int]
                if (v == null) {
                    r += "null"
                } else if (v.isInstanceOf[Boolean]) {
                    r += (if (v.asInstanceOf[Boolean]) "true" else "false")
                } else if (v.isInstanceOf[String]) {
                    r += "\"" + escapeString(v.asInstanceOf[String]) + "\""
                } else if (v.isInstanceOf[Int] || v.isInstanceOf[Long] || v.isInstanceOf[Double] || v.isInstanceOf[Float]) {
                    r += v.toString
                } else if (v.isInstanceOf[ArrayBuffer[?]]) {
                    val lv = v.asInstanceOf[ArrayBuffer[Any]]
                    if (lv.length == 0) {
                        r += "[]"
                    } else {
                        val childD = curD + 1
                        s.append(initDict(
                            "t"-> "r",
                            "v"-> (if (p) "\n" + t.repeat(curD) + "]" else "]"),
                            "d"-> curD,
                        ))
                        var i = lv.length
                        while (i > 0) {
                            i -= 1
                            s.append(initDict(
                                "t"-> "v",
                                "v"-> lv(i),
                                "d"-> childD,
                            ))
                            if (i > 0) {
                                s.append(initDict(
                                    "t"-> "r",
                                    "v"-> (if (p) ",\n" + t.repeat(childD) else ","),
                                    "d"-> childD,
                                ))
                            }
                        }
                        s.append(initDict(
                            "t"-> "r",
                            "v"-> (if (p) "[\n" + t.repeat(childD) else "["),
                            "d"-> childD,
                        ))
                    }
                } else if (v.isInstanceOf[MutableMap[?, ?]]) {
                    val dv = v.asInstanceOf[MutableMap[String, Any]]
                    if (dv.isEmpty) {
                        r += "{}"
                    } else {
                        val childD = curD + 1
                        s.append(initDict(
                            "t"-> "r",
                            "v"-> (if (p) "\n" + t.repeat(curD) + "}" else "}"),
                            "d"-> curD,
                        ))
                        val dpl = dv.toArray
                        var i = dpl.length
                        while (i > 0) {
                            i -= 1
                            val dp = dpl(i)
                            val dK = dp._1
                            val dV = dp._2
                            s.append(initDict(
                                "t"-> "v",
                                "v"-> dV,
                                "d"-> childD,
                            ))
                            s.append(initDict(
                                "t"-> "r",
                                "v"-> (if (p) "\"" + dK + "\": " else "\"" + dK + "\":"),
                                "d"-> childD,
                            ))
                            if (i > 0) {
                                s.append(initDict(
                                    "t"-> "r",
                                    "v"-> (if (p) ",\n" + t.repeat(childD) else ","),
                                    "d"-> childD,
                                ))
                            }
                        }
                        s.append(initDict(
                            "t"-> "r",
                            "v"-> (if (p) "{\n" + t.repeat(childD) else "{"),
                            "d"-> childD,
                        ))
                    }
                } else if (v.isInstanceOf[Function1[?, ?]]) {
                    r += "\"[object Function]\""
                } else {
                    r += "\"" + v.getClass.getSimpleName + "\""
                }
            }
        }
        return r
    }
}
