package willyhorizont.runtime

import scala.collection.mutable.{Map => MutableMap, ArrayBuffer}

object Xl {
    def list(els: Any*): Any = {
        val l = ArrayBuffer[Any]()
        els.foreach((el) => {
            l.append(el)
        })
        return l
    }

    def dict(pairs: (String, Any)*): Any = {
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
        val s = ArrayBuffer[MutableMap[String, Any]]()
        val initStkEl = MutableMap[String, Any]()
        initStkEl.put("t", "v")
        initStkEl.put("v", a)
        initStkEl.put("d", 0)
        s.append(initStkEl)
        var r = ""
        while (s.length > 0) {
            val c = s.remove(s.length - 1)
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
                        val slcb = MutableMap[String, Any]()
                        slcb.put("t", "r")
                        slcb.put("v", if (p) "\n" + t.repeat(curD) + "]" else "]")
                        slcb.put("d", curD)
                        s.append(slcb)
                        var i = lv.length
                        while (i > 0) {
                            i -= 1
                            val slel = MutableMap[String, Any]()
                            slel.put("t", "v")
                            slel.put("v", lv(i))
                            slel.put("d", childD)
                            s.append(slel)
                            if (i > 0) {
                                val slelsep = MutableMap[String, Any]()
                                slelsep.put("t", "r")
                                slelsep.put("v", if (p) ",\n" + t.repeat(childD) else ",")
                                slelsep.put("d", childD)
                                s.append(slelsep)
                            }
                        }
                        val slob = MutableMap[String, Any]()
                        slob.put("t", "r")
                        slob.put("v", if (p) "[\n" + t.repeat(childD) else "[")
                        slob.put("d", childD)
                        s.append(slob)
                    }
                } else if (v.isInstanceOf[MutableMap[?, ?]]) {
                    val dv = v.asInstanceOf[MutableMap[String, Any]]
                    if (dv.isEmpty) {
                        r += "{}"
                    } else {
                        val childD = curD + 1
                        val sdcb = MutableMap[String, Any]()
                        sdcb.put("t", "r")
                        sdcb.put("v", if (p) "\n" + t.repeat(curD) + "}" else "}")
                        sdcb.put("d", curD)
                        s.append(sdcb)
                        val entries = dv.toArray
                        var i = entries.length
                        while (i > 0) {
                            i -= 1
                            val pair = entries(i)
                            val dK = pair._1
                            val dV = pair._2
                            val sdel = MutableMap[String, Any]()
                            sdel.put("t", "v")
                            sdel.put("v", dV)
                            sdel.put("d", childD)
                            s.append(sdel)
                            val sdkvsep = MutableMap[String, Any]()
                            sdkvsep.put("t", "r")
                            sdkvsep.put("v", if (p) "\"" + dK + "\": " else "\"" + dK + "\":")
                            sdkvsep.put("d", childD)
                            s.append(sdkvsep)
                            if (i > 0) {
                                val sdpelsep = MutableMap[String, Any]()
                                sdpelsep.put("t", "r")
                                sdpelsep.put("v", if (p) ",\n" + t.repeat(childD) else ",")
                                sdpelsep.put("d", childD)
                                s.append(sdpelsep)
                            }
                        }
                        val sdob = MutableMap[String, Any]()
                        sdob.put("t", "r")
                        sdob.put("v", if (p) "{\n" + t.repeat(childD) else "{")
                        sdob.put("d", childD)
                        s.append(sdob)
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
