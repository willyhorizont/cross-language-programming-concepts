vim9script

export def Echoln(a: any)
    for ln in split(a, "\n")
        echomsg ln
    endfor
enddef

export def EscapeString(s: string): string
    var r = s
    r = substitute(r, '\\', '\\\\', 'g')
    r = substitute(r, '"', '\\"', 'g')
    r = substitute(r, "\n", '\\n', 'g')
    r = substitute(r, "\r", '\\r', 'g')
    r = substitute(r, "\t", '\\t', 'g')
    return r
enddef

def PrettifyJsonString(jsonStr: string): string
    var r = ""
    var t = 0
    var inStr = false
    var i = 0
    var sLen = len(jsonStr)
    while i < sLen
        var c = jsonStr[i]
        if c == "\"" && (i == 0 || jsonStr[i - 1] != "\\")
            inStr = !inStr
        endif
        if !inStr
            if c == "{" || c == "["
                t += 4
                r ..= c .. "\n" .. repeat(" ", t)
            elseif c == "}" || c == "]"
                t -= 4
                r ..= "\n" .. repeat(" ", t) .. c
            elseif c == ","
                r ..= ",\n" .. repeat(" ", t)
            elseif c == ":"
                r ..= ": "
            else
                r ..= c
            endif
        else
            r ..= c
        endif
        i += 1
    endwhile
    return r
enddef

export def StdJsonStringify(a: any, op: dict<any> = {}): string
    var r = {"v": a}
    var s: list<dict<any>> = [{"t": r, "k": "v", "v": a}]
    while !empty(s)
        var c = remove(s, -1)
        var t = c["t"]
        var k = c["k"]
        var v = c["v"]
        if type(v) == v:t_func
            t[k] = "[object Function]"
            continue
        endif
        if type(v) == v:t_list
            var nL: list<any> = []
            t[k] = nL
            var idx = len(v) - 1
            while idx >= 0
                add(s, {"t": nL, "k": idx, "v": v[idx]})
                idx -= 1
            endwhile
            continue
        endif
        if type(v) == v:t_dict
            var nD: dict<any> = {}
            t[k] = nD
            var p_list: list<dict<any>> = []
            for [pK, pV] in items(v)
                add(p_list, {"pK": pK, "pV": pV})
            endfor
            var idx = len(p_list) - 1
            while idx >= 0
                var p = p_list[idx]
                add(s, {"t": nD, "k": p["pK"], "v": p["pV"]})
                idx -= 1
            endwhile
            continue
        endif
        t[k] = v
    endwhile
    var jifyS = json_encode(r["v"])
    if has_key(op, "pretty") && op["pretty"] == true
        return PrettifyJsonString(jifyS)
    endif
    return jifyS
enddef

export def JsonStringify(a: any, op: dict<any> = {}): string
    var p = has_key(op, "pretty") ? op["pretty"] == true : false
    var t = repeat(" ", 4)
    var s = [{"t": "v", "v": a, "d": 0}]
    var r = ""
    while !empty(s)
        var c = remove(s, -1)
        if c["t"] == "r"
            r ..= c["v"]
            continue
        endif
        var v = c["v"]
        var curD = c["d"]
        if type(v) == v:t_none
            r ..= "null"
            continue
        endif
        if type(v) == v:t_bool
            r ..= (v ? "true" : "false")
            continue
        endif
        if type(v) == v:t_string
            r ..= "\"" .. EscapeString(v) .. "\""
            continue
        endif
        if type(v) == v:t_number || type(v) == v:t_float
            r ..= v
            continue
        endif
        if type(v) == v:t_func
            r ..= "\"[object Function]\""
            continue
        endif
        if type(v) == v:t_list
            if empty(v)
                r ..= "[]"
                continue
            endif
            var childD = curD + 1
            add(s, {
                "t": "r",
                "v": p ? "\n" .. repeat(t, curD) .. "]" : "]",
                "d": curD
            })
            var i = len(v) - 1
            while i >= 0
                add(s, {
                    "t": "v",
                    "v": v[i],
                    "d": childD
                })
                if i > 0
                    add(s, {
                        "t": "r",
                        "v": p ? "," .. "\n" .. repeat(t, childD) : ",",
                        "d": childD
                    })
                endif
                i -= 1
            endwhile
            add(s, {
                "t": "r",
                "v": p ? "[" .. "\n" .. repeat(t, childD) : "[",
                "d": childD
            })
            continue
        endif
        if type(v) == v:t_dict
            if empty(v)
                r ..= "{}"
                continue
            endif
            var childD = curD + 1
            add(s, {
                "t": "r",
                "v": p ? "\n" .. repeat(t, curD) .. "}" : "}",
                "d": curD
            })
            var dpL = items(v)
            var i = len(dpL) - 1
            while i >= 0
                var dK = dpL[i][0]
                var dV = dpL[i][1]
                add(s, {
                    "t": "v",
                    "v": dV,
                    "d": childD
                })
                add(s, {
                    "t": "r",
                    "v": p ? "\"" .. dK .. "\": " : "\"" .. dK .. "\":",
                    "d": childD
                })
                if i > 0
                    add(s, {
                        "t": "r",
                        "v": p ? "," .. "\n" .. repeat(t, childD) : ",",
                        "d": childD
                    })
                endif
                i -= 1
            endwhile
            add(s, {
                "t": "r",
                "v": p ? "{" .. "\n" .. repeat(t, childD) : "{",
                "d": childD
            })
            continue
        endif
        r ..= "\"" .. typename(v) .. "\""
    endwhile
    return r
enddef
