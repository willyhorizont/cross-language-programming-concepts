package willyhorizont.runtime {
    import flash.display.Sprite;
    import flash.utils.getQualifiedClassName;
    import willyhorizont.runtime.Terminal;

    public class Xl extends Sprite {
        public function Xl() {
            var t:Terminal = new Terminal();
            addChild(t);
        }
        public static function getType(a:*):String {
            var aT:String = getQualifiedClassName(a);
            switch (aT) {
                case "null":
                    return "[object XlNone]";
                    break;
                case "Boolean":
                    return "[object XlBool]";
                    break;
                case "String":
                    return "[object XlString]";
                    break;
                case "int":
                    return "[object XlInt]";
                    break;
                case "Number":
                    return "[object XlFloat]";
                    break;
                case "Array":
                    return "[object XlList]";
                    break;
                case "Object":
                    return "[object XlDict]";
                    break;
                case "Function":
                    return "[object XlLambda]";
                    break;
                default:
                    return "[object [ActionScript[\"" + aT + "\"]]";
                    break;
            }
        }
        public static function stringRepeat(s:String, d:int):String {
            var nS:String = "";
            for (var i:int = 0; i < d; i += 1) {
                nS += s;
            }
            return nS;
        };
        public static function listReduce(a:Array, c:Function, iV:* = null):* {
            var i:int = 0;
            var ac:* = iV;
            if ((iV === null) && (a.length > 0)) {
                ac = a[0];
                i = 1;
            }
            for (i; i < a.length; i += 1) {
                ac = c(ac, a[i], i, a);
            }
            return ac;
        }
        public static function dictToList(d:Object):Array {
            var l:Array = [];
            if (d == null) return l;
            for (var k:String in d) {
                l.push({ "key": k, "value": d[k] });
            }
            return l;
        }
        public static function dictFromList(el:Array):Object {
            var d:Object = {};
            if (d == null) return d;
            for (var i:int = 0; i < el.length; i += 1) {
                var p:Array = el[i] as Array;
                if ((p != null) && (p.length >= 2)) {
                    var key:String = String(p[0]);
                    var val:* = p[1];
                    d[key] = val;
                }
            }
            return d;
        }
        public static function escapeString(s:String):String {
            if (s == null) return "";
            var r:String = s;
            r = r.replace(new RegExp("\\\\", "g"), "\\\\");
            r = r.replace(new RegExp("\"", "g"), "\\\"");
            r = r.replace(new RegExp("\n", "g"), "\\n");
            r = r.replace(new RegExp("\r", "g"), "\\r");
            r = r.replace(new RegExp("\t", "g"), "\\t");
            return r;
        }
        public static function jsonStringify(a:*, o:Object = null):String {
            var p:Boolean = false;
            if (o != null && o.hasOwnProperty("pretty")) {
                p = Boolean(o["pretty"]);
            }
            var t:String = stringRepeat(" ", 4);
            var s:Array = [{ "t": "v", "v": a, "d": 0 }];
            var r:String = "";
            while (s.length > 0) {
                var c:Object = s.pop();
                if (c["t"] === "r") {
                    r += c["v"];
                    continue;
                }
                var v:* = c["v"];
                var curD:int = int(c["d"]);
                if (v === null || v === undefined) {
                    r += "null";
                    continue;
                }
                var curT:String = getType(v);
                if (curT === "[object XlBool]") {
                    r += v ? "true" : "false";
                    continue;
                }
                if (curT === "[object XlString]") {
                    r += "\"" + escapeString(v) + "\"";
                    continue;
                }
                if (curT === "[object XlInt]" || curT === "[object XlFloat]") {
                    r += v.toString();
                    continue;
                }
                if (curT === "[object XlLambda]") {
                    r += "\"[object Function]\"";
                    continue;
                }
                if (curT === "[object XlList]") {
                    if (v.length === 0) {
                        r += "[]";
                        continue;
                    }
                    var childDd:int = curD + 1;
                    s.push({
                        "t": "r",
                        "v": p ? "\n" + stringRepeat(t, curD) + "]" : "]",
                        "d": curD
                    });
                    for (var i:int = v.length - 1; i >= 0; i -= 1) {
                        s.push({
                            "t": "v",
                            "v": v[i],
                            "d": childDd
                        });
                        if (i > 0) {
                            s.push({
                                "t": "r",
                                "v": p ? ",\n" + stringRepeat(t, childDd) : ",",
                                "d": childDd
                            });
                        }
                    }
                    s.push({
                        "t": "r",
                        "v": p ? "[\n" + stringRepeat(t, childDd) : "[",
                        "d": childDd
                    });
                    continue;
                }
                if (curT === "[object XlDict]") {
                    var dL:Array = dictToList(v);
                    if (dL.length === 0) {
                        r += "{}";
                        continue;
                    }
                    var childDl:int = curD + 1;
                    s.push({
                        "t": "r",
                        "v": p ? "\n" + stringRepeat(t, curD) + "}" : "}",
                        "d": curD
                    });
                    for (var k:int = dL.length - 1; k >= 0; k -= 1) {
                        var dI:Object = dL[k];
                        var dk:String = dI["key"];
                        var dV:* = dI["value"];
                        s.push({
                            "t": "v",
                            "v": dV,
                            "d": childDl
                        });
                        s.push({
                            "t": "r",
                            "v": p ? "\"" + String(dk) + "\": " : "\"" + String(dk) + "\":",
                            "d": childDl
                        });
                        if (k > 0) {
                            s.push({
                                "t": "r",
                                "v": p ? ",\n" + stringRepeat(t, childDl) : ",",
                                "d": childDl
                            });
                        }
                    }
                    s.push({
                        "t": "r",
                        "v": p ? "{\n" + stringRepeat(t, childDl) : "{",
                        "d": childDl
                    });
                    continue;
                }
                r += "\"" + curT + "\"";
            }
            return r;
        }
    }
}
