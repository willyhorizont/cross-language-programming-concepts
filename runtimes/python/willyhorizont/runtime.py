def get_type(a):
    if a is None:
        return "XlNone"
    if isinstance(a, bool):
        return "XlBool"
    if isinstance(a, str):
        return "XlString"
    if isinstance(a, int):
        return "XlInt"
    if isinstance(a, float):
        return "XlFloat"
    if isinstance(a, dict):
        return "XlDict"
    if isinstance(a, list):
        return "XlList"
    if callable(a):
        return "XlClosure"
    return str(type(a))


def json_stringify(a, pretty=False):
    p = pretty
    t = " " * 4
    s = [{"t": "v", "v": a, "d": 0}]
    r = ""
    while len(s) > 0:
        c = s.pop()
        v = c["v"]
        if c["t"] == "r":
            r+= v
            continue
        cur_t = c["d"]
        if v is None:
            r += "null"
            continue
        if isinstance(v, bool):
            r += "true" if v else "false"
            continue
        if isinstance(v, str):
            r += f"\"{v}\""
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
            child_t = cur_t + 1
            s.append({
                "t": "r",
                "v": f"\n{t * cur_t}]" if p else "]",
                "d": cur_t
            })
            for i in range(len(v) - 1, -1, -1):
                s.append({
                    "t": "v",
                    "v": v[i],
                    "d": child_t
                })
                if i > 0:
                    s.append({
                        "t": "r",
                        "v": f",\n{t * child_t}" if p else ",",
                        "d": child_t
                    })
            s.append({
                "t": "r",
                "v": f"[\n{t * child_t}" if p else "[",
                "d": child_t
            })
            continue
        if isinstance(v, dict):
            de = list(v.items())
            if len(de) == 0:
                r += "{}"
                continue
            child_t = cur_t + 1
            s.append({
                "t": "r",
                "v": "\n" + t * cur_t + "}" if p else "}",
                "d": cur_t
            })
            for i in range(len(de) - 1, -1, -1):
                dk, dict_value = de[i]
                s.append({
                    "t": "v",
                    "v": dict_value,
                    "d": child_t
                })
                s.append({
                    "t": "r",
                    "v": f"\"{dk}\": " if p else f"\"{dk}\":",
                    "d": child_t
                })
                if i > 0:
                    s.append({
                        "t": "r",
                        "v": f",\n{t * child_t}" if p else ",",
                        "d": child_t
                    })
            s.append({
                "t": "r",
                "v": f"{{\n{t * child_t}" if p else "{",
                "d": child_t
            })
            continue
        r += f"\"{type(v).__name__}\""
    return r

