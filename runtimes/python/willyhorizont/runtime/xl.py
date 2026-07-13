def escape_string(s):
    if s is None:
        return ""
    r = str(s)
    r = r.replace("\\", "\\\\")
    r = r.replace("\"", "\\\"")
    r = r.replace("\n", "\\n")
    r = r.replace("\r", "\\r")
    r = r.replace("\t", "\\t")
    return r


def json_stringify(a, pretty=False):
    p = pretty
    t = " " * 4
    s = [{"t": "v", "v": a, "d": 0}]
    r = ""
    while len(s) > 0:
        c = s.pop()
        if c["t"] == "r":
            r+= c["v"]
            continue
        v = c["v"]
        cur_d = c["d"]
        if v is None:
            r += "null"
            continue
        if isinstance(v, bool):
            r += "true" if v else "false"
            continue
        if isinstance(v, str):
            r += f"\"{escape_string(v)}\""
            continue
        if isinstance(v, (int, float)):
            r += str(v)
            continue
        if callable(v):
            r += "\"[object Function]\""
            continue
        if isinstance(v, list):
            if len(v) == 0:
                r += "[]"
                continue
            child_d = cur_d + 1
            s.append({
                "t": "r",
                "v": f"\n{t * cur_d}]" if p else "]",
                "d": cur_d
            })
            for i in range(len(v) - 1, -1, -1):
                s.append({
                    "t": "v",
                    "v": v[i],
                    "d": child_d
                })
                if i > 0:
                    s.append({
                        "t": "r",
                        "v": f",\n{t * child_d}" if p else ",",
                        "d": child_d
                    })
            s.append({
                "t": "r",
                "v": f"[\n{t * child_d}" if p else "[",
                "d": child_d
            })
            continue
        if isinstance(v, dict):
            dpl = list(v.items())
            if len(dpl) == 0:
                r += "{}"
                continue
            child_d = cur_d + 1
            s.append({
                "t": "r",
                "v": "\n" + t * cur_d + "}" if p else "}",
                "d": cur_d
            })
            for i in range(len(dpl) - 1, -1, -1):
                dk, dv = dpl[i]
                s.append({
                    "t": "v",
                    "v": dv,
                    "d": child_d
                })
                s.append({
                    "t": "r",
                    "v": f"\"{dk}\": " if p else f"\"{dk}\":",
                    "d": child_d
                })
                if i > 0:
                    s.append({
                        "t": "r",
                        "v": f",\n{t * child_d}" if p else ",",
                        "d": child_d
                    })
            s.append({
                "t": "r",
                "v": f"{{\n{t * child_d}" if p else "{",
                "d": child_d
            })
            continue
        r += f"\"{type(v).__name__}\""
    return r

