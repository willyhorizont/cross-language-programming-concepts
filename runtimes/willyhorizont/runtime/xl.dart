dynamic toList(dynamic l) {
	dynamic t = l.runtimeType.toString();
	if (!t.contains("dynamic") && !t.contains("Object?")) {
		return List<dynamic>.from(l as Iterable);
	}
	return l;
}

dynamic toDict(dynamic d) {
	dynamic t = d.runtimeType.toString();
	if (!t.contains("dynamic") && !t.contains("Object?")) {
		return Map<dynamic, dynamic>.from(d as Map);
	}
	return d;
}

dynamic push(dynamic l, dynamic item) {
	dynamic t = l.runtimeType.toString();
	if (!t.contains("dynamic") && !t.contains("Object?")) {
		var nl = List<dynamic>.from(l as Iterable);
		nl.add(item);
		return nl;
	}
	l.add(item);
	return l;
}

dynamic set(dynamic d, dynamic k, dynamic v) {
	dynamic t = d.runtimeType.toString();
	if (!t.contains("dynamic") && !t.contains("Object?")) {
		var nd = Map<dynamic, dynamic>.from(d as Map);
		nd[k] = v;
		return nd;
	}
	d[k] = v;
	return d;
}

dynamic escapeString(dynamic s) {
    if (s == null) return "";
    dynamic r = s.toString();
    r = r.replaceAll("\\", "\\\\");
    r = r.replaceAll("\"", "\\\"");
    r = r.replaceAll("\n", "\\n");
    r = r.replaceAll("\r", "\\r");
    r = r.replaceAll("\t", "\\t");
    return r;
}

dynamic jsonStringify(dynamic o, {dynamic pretty = false}) {
    dynamic p = pretty;
    dynamic t = " " * 4;
    dynamic s = [{"t": "v", "v": o, "d": 0}];
    dynamic r = "";
    while (s.isNotEmpty) {
        dynamic c = s.removeLast();
        if (c["t"] == "r") {
            r += c["v"];
            continue;
        }
        dynamic v = c["v"];
        dynamic curD = c["d"];
        if (v == null) {
            r += "null";
            continue;
        }
        if (v is bool) {
            r += v ? "true" : "false";
            continue;
        }
        if (v is String) {
            r += "\"" + escapeString(v) + "\"";
            continue;
        }
        if (v is num) {
            r += v.toString();
            continue;
        }
        if (v is Function) {
            r += "\"[object Function]\"";
            continue;
        }
        if (v is List) {
            if (v.isEmpty) {
                r += "[]";
                continue;
            }
            dynamic childD = curD + 1;
            s.add({
                "t": "r",
                "v": p ? "\n" + (t * curD) + "]" : "]",
                "d": curD
            });
            for (dynamic i = v.length - 1; i >= 0; i -= 1) {
                s.add({
                    "t": "v",
                    "v": v[i],
                    "d": childD
                });
                if (i > 0) {
                    s.add({
                        "t": "r",
                        "v": p ? ",\n" + (t * childD) : ",",
                        "d": childD
                    });
                }
            }
            s.add({
                "t": "r",
                "v": p ? "[\n" + (t * childD) : "[",
                "d": childD
            });
            continue;
        }
        if (v is Map) {
            dynamic dpL = v.entries.toList();
            if (dpL.isEmpty) {
                r += "{}";
                continue;
            }
            dynamic childD = curD + 1;
            s.add({
                "t": "r",
                "v": p ? "\n" + (t * curD) + "}" : "}",
                "d": curD
            });
            for (dynamic i = dpL.length - 1; i >= 0; i -= 1) {
                dynamic dP = dpL[i];
                s.add({
                    "t": "v",
                    "v": dP.value,
                    "d": childD
                });
                s.add({
                    "t": "r",
                    "v": p ? "\"" + dP.key.toString() + "\": " : "\"" + dP.key.toString() + "\":",
                    "d": childD
                });
                if (i > 0) {
                    s.add({
                        "t": "r",
                        "v": p ? ",\n" + (t * childD) : ",",
                        "d": childD
                    });
                }
            }
            s.add({
                "t": "r",
                "v": p ? "{\n" + (t * childD) : "{",
                "d": childD
            });
            continue;
        }
        r += "\"" + v.runtimeType.toString() + "\"";
    }
    return r;
}
