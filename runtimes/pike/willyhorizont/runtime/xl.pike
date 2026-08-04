void writeln(mixed ... va) {
    mixed s = "";
    for(mixed i = 0; i < sizeof(va); i += 1) {
        mixed el = va[i];
        s += el;
    }
    write(s + "\n");
}

mixed escape_string(mixed s) {
    if (s == 0 || s == UNDEFINED) return "";
    mixed r = s;
    r = replace(r, ([
        "\\" : "\\\\",
        "\"" : "\\\"",
        "\n" : "\\n",
        "\r" : "\\r",
        "\t" : "\\t",
    ]));
    return r;
}

mixed json_stringify(mixed a, mapping|void o) {
    mixed p = 0;
    if (o && o["pretty"]) {
        p = 1;
    }
    mixed t = " " * 4;
    mixed s = ({ ([ "t": "v", "v": a, "d": 0 ]) });
    mixed r = "";
    while (sizeof(s) > 0) {
        mapping c = s[sizeof(s) - 1];
        s = s[0..sizeof(s) - 2];
        if (c["t"] == "r") {
            r += c["v"];
            continue;
        }
        mixed v = c["v"];
        mixed curd = c["d"];
        if (stringp(v)) {
            r += "\"" + escape_string(v) + "\"";
            continue;
        }
        if (intp(v) || floatp(v)) {
            r += v;
            continue;
        }
        if (functionp(v)) {
            r += "\"[object Function]\"";
            continue;
        }
        if (arrayp(v)) {
            if (sizeof(v) == 0) {
                r += "[]";
                continue;
            }
            mixed childd = curd + 1;
            if (p) {
                s += ({ ([
                    "t": "r",
                    "v": "\n" + (t * curd) + "]",
                    "d": curd,
                ]) });
            } else {
                s += ({ ([
                    "t": "r",
                    "v": "]",
                    "d": curd,
                ]) });
            }
            for (mixed i = sizeof(v) - 1; i >= 0; i -= 1) {
                s += ({ ([
                    "t": "v",
                    "v": v[i],
                    "d": childd,
                ]) });
                if (i > 0) {
                    if (p) {
                        s += ({ ([
                            "t": "r",
                            "v": ",\n" + (t * childd),
                            "d": childd,
                        ]) });
                    } else {
                        s += ({ ([
                            "t": "r",
                            "v": ",",
                            "d": childd,
                        ]) });
                    }
                }
            }
            if (p) {
                s += ({ ([
                    "t": "r",
                    "v": "[\n" + (t * childd),
                    "d": curd,
                ]) });
            } else {
                s += ({ ([
                    "t": "r",
                    "v": "[",
                    "d": curd,
                ]) });
            }
            continue;
        }
        if (mappingp(v)) {
            array pk = indices(v);
            array pv = values(v);
            if (sizeof(pk) == 0) {
                r += "{}";
                continue;
            }
            mixed childd = curd + 1;
            if (p) {
                s += ({ ([
                    "t": "r",
                    "v": "\n" + (t * curd) + "}",
                    "d": curd,
                ]) });
            } else {
                s += ({ ([
                    "t": "r",
                    "v": "}",
                    "d": curd,
                ]) });
            }
            for (mixed i = sizeof(pk) - 1; i >= 0; i -= 1) {
                s += ({ ([
                    "t": "v",
                    "v": pv[i],
                    "d": childd,
                ]) });
                if (p) {
                    s += ({ ([
                        "t": "r",
                        "v": "\"" + pk[i] + "\": ",
                        "d": childd,
                    ]) });
                } else {
                    s += ({ ([
                        "t": "r",
                        "v": "\"" + pk[i] + "\":",
                        "d": childd,
                    ]) });
                }
                if (i > 0) {
                    if (p) {
                        s += ({ ([
                            "t": "r",
                            "v": ",\n" + (t * childd),
                            "d": childd,
                        ]) });
                    } else {
                        s += ({ ([
                            "t": "r",
                            "v": ",",
                            "d": childd,
                        ]) });
                    }
                }
            }
            if (p) {
                s += ({ ([
                    "t": "r",
                    "v": "{\n" + (t * childd),
                    "d": curd,
                ]) });
            } else {
                s += ({ ([
                    "t": "r",
                    "v": "{",
                    "d": curd,
                ]) });
            }
            continue;
        }
        if (objectp(v)) {
            r += "\"[object [Pike " + sprintf("%O", v) + "]]\"";
            continue;
        }
    }
    return r;
}
