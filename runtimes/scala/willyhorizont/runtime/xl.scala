package willyhorizont.runtime

import scala.collection.mutable.{Map => MutableMap, ArrayBuffer}
import scala.collection.{Seq}

object Xl {
    type List = ArrayBuffer[Any]
    type Dict = MutableMap[String, Any]
    type Lambda = Any => Any
    def iter(va: Any): Any = {
        va match {
            case itr: Iterator[?] => itr
            case l: ArrayBuffer[?] => l.iterator
            case l: Seq[?] => l.iterator
            case _ => throw new RuntimeException("XlRuntimeError: Expected List.")
        }
    }
    def next(itr: Any): Any = {
        itr match {
            case itr: Iterator[?] => if (itr.hasNext) itr.next() else null
            case _ => throw new RuntimeException("XlRuntimeError: Expected Iterator.")
        }
    }
    def call(c: Any, va: Any*): Any = {
        if (c.isInstanceOf[Function1[?, ?]]) return c.asInstanceOf[Lambda](va.toSeq)
        throw new RuntimeException("XlRuntimeError: Expected Lambda.")
    }
    def initList(ell: Any*): Any = {
        val l = ArrayBuffer[Any]()
        ell.foreach((el) => {
            l.append(el)
        })
        return l
    }
    def initDict(pairs: (String, Any)*): Any = {
        val d = MutableMap[String, Any]()
        pairs.foreach { case (k, v) => {
            d.put(k, v)
        } }
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
        val s = initList(initDict("t"-> "v", "v"-> a, "d"-> 0)).asInstanceOf[List]
        var r = ""
        while (s.length > 0) {
            val c = s.remove(s.length - 1).asInstanceOf[Dict]
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
                    val lv = v.asInstanceOf[List]
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
                    val dv = v.asInstanceOf[Dict]
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
