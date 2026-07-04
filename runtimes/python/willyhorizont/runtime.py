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
        if c["t"] == "r":
            r+= c["v"]
            continue
        v = c["v"]
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
                dk, dv = de[i]
                s.append({
                    "t": "v",
                    "v": dv,
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


json_stringify_a = lambda a, pretty=False: [
    (p := pretty),
    (t := " " * 4),
    (s := [{"t": "v", "v": a, "d": 0}]),
    (r := ""),
    [
        (
            (r := r + c["v"]) if c["t"] == "r"
            else (
                (v := c["v"]),
                (cur_t := c["d"]),
                (
                    (r := r + "null") if v is None
                    else (r := r + ("true" if v else "false")) if isinstance(v, bool)
                    else (r := r + f"\"{v}\"") if isinstance(v, str)
                    else (r := r + str(v)) if isinstance(v, (int, float))
                    else (r := r + "\"[object Function]\"") if callable(v)
                    else (
                        (r := r + "[]") if len(v) == 0
                        else (
                            (child_t := cur_t + 1),
                            s.append({
                                "t": "r",
                                "v": f"\n{t * cur_t}]" if p else "]",
                                "d": cur_t
                            }),
                            [
                                (
                                    s.append({
                                        "t": "v",
                                        "v": v[i],
                                        "d": child_t
                                    }),
                                    s.append({
                                        "t": "r",
                                        "v": f",\n{t * child_t}" if p else ",",
                                        "d": child_t
                                    }) if i > 0 else None
                                ) for i in range(len(v) - 1, -1, -1)
                            ],
                            s.append({
                                "t": "r",
                                "v": f"[\n{t * child_t}" if p else "[",
                                "d": child_t
                            })
                        )
                    ) if isinstance(v, list)
                    else (
                        (r := r + "{}") if len(de := list(v.items())) == 0
                        else (
                            (child_t := cur_t + 1),
                            s.append({
                                "t": "r",
                                "v": "\n" + t * cur_t + "}" if p else "}",
                                "d": cur_t
                            }),
                            [
                                (lambda dk, dv: (
                                    s.append({
                                        "t": "v",
                                        "v": dv,
                                        "d": child_t
                                    }),
                                    s.append({
                                        "t": "r",
                                        "v": f"\"{dk}\": " if p else f"\"{dk}\":",
                                        "d": child_t
                                    }),
                                    s.append({
                                        "t": "r",
                                        "v": f",\n{t * child_t}" if p else ",",
                                        "d": child_t
                                    }) if i > 0 else None
                                ))(de[i][0], de[i][1]) for i in range(len(de) - 1, -1, -1)
                            ],
                            s.append({
                                "t": "r",
                                "v": f"{{\n{t * child_t}" if p else "{",
                                "d": child_t
                            })
                        )
                    ) if isinstance(v, dict)
                    else (r := r + f"\"{type(v).__name__}\"")
                )
            )
        )
        for _ in (iter(lambda: len(s) > 0, False) if len(s) > 0 else [])
        if (c := s.pop()) or True
    ],
    r
][-1]
