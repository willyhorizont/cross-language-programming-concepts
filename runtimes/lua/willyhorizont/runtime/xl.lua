local XL = {}

local escapeString = function(s)
    if s == nil then return "" end
    local r = tostring(s)
    r = r:gsub("\\", "\\\\")
    r = r:gsub("\"", "\\\"")
    r = r:gsub("\n", "\\n")
    r = r:gsub("\r", "\\r")
    r = r:gsub("\t", "\\t")
    return r
end

local is_none = function (a) return (type(a) == "nil") end
local is_bool = function (a) return (type(a) == "boolean") end
local is_string = function (a) return (type(a) == "string") end

local is_int = function (a)
    if type(a) ~= "number" then return false end
    if math.type then return math.type(a) == "integer" end
    return a == math.floor(a)
end

local is_float = function (a)
    if type(a) ~= "number" then return false end
    if math.type then return math.type(a) == "float" end
    return a ~= math.floor(a)
end

local is_closure = function (a) return (type(a) == "function") end

local is_list = function (a)
    if type(a) ~= "table" then return false end
    if next(a) == nil then return true, 0 end
    local i = 1
    local last_k = nil
    for k, _ in pairs(a) do
        if not is_int(k) then return false end
        if k < 1 then return false end
        i = k
        last_k = k
    end
    if last_k == nil then return false end
    return true, i
end

local is_dict = function (a)
    if type(a) ~= "table" then return false end
    local i = 1
    local last_k = nil
    for k, _ in pairs(a) do
        if type(k) ~= "string" then return false end
        i = i + 1
        last_k = k
    end
    if last_k == nil then return false end
    return true, i
end

local dict_to_list = function (d)
    local nl = {}
    for k, v in pairs(d) do
        table.insert(nl, {k, v})
    end
    return nl
end

local json_stringify = function (a, o)
    local p = ((o or {})["pretty"] == nil) and false or (o or {})["pretty"]
    local t = string.rep(" ", 4)
    local s = { {["t"] = "v", ["v"] = a, ["d"] = 0} }
    local r = ""
    while #s > 0 do
        local c = table.remove(s)
        if c["t"] == "r" then
            r = r .. c["v"]
            goto next_iteration
        end
        local v = c["v"]
        local cur_t = c["d"]
        local ct = type(v)
        if v == nil then
            r = r .. "null"
            goto next_iteration
        end
        if ct == "boolean" then
            r = r .. (v and "true" or "false")
            goto next_iteration
        end
        if ct == "string" then
            r = r .. "\"" .. escapeString(v) .. "\""
            goto next_iteration
        end
        if ct == "number" then
            r = r .. tostring(v)
            goto next_iteration
        end
        if ct == "function" then
            r = r .. "\"[object Function]\""
            goto next_iteration
        end
        local is_l, ll = is_list(v)
        if is_l then
            if ll == 0 then
                r = r .. "[]"
                goto next_iteration
            end
            local child_t = cur_t + 1
            table.insert(s, {
                ["t"] = "r",
                ["v"] = p and ("\n" .. string.rep(t, cur_t) .. "]") or "]",
                ["d"] = cur_t
            })
            for i = ll, 1, -1 do
                table.insert(s, {
                    ["t"] = "v",
                    ["v"] = v[i],
                    ["d"] = child_t
                })
                if i > 1 then
                    table.insert(s, {
                        ["t"] = "r",
                        ["v"] = p and (",\n" .. string.rep(t, child_t)) or ",",
                        ["d"] = child_t
                    })
                end
            end
            table.insert(s, {
                ["t"] = "r",
                ["v"] = p and ("[\n" .. string.rep(t, child_t)) or "[",
                ["d"] = child_t
            })
            goto next_iteration
        end
        local is_d, dkl = is_dict(v)
        if is_d then
            local de = dict_to_list(v)
            local child_t = cur_t + 1
            table.insert(s, {
                ["t"] = "r",
                ["v"] = p and ("\n" .. string.rep(t, cur_t) .. "}") or "}",
                ["d"] = cur_t
            })
            for i = #de, 1, -1 do
                local dk, dv = de[i][1], de[i][2]
                table.insert(s, {
                    ["t"] = "v",
                    ["v"] = dv,
                    ["d"] = child_t
                })
                table.insert(s, {
                    ["t"] = "r",
                    ["v"] = p and ("\"" .. dk .. "\": ") or ("\"" .. dk .. "\":"),
                    ["d"] = child_t
                })
                if i > 1 then
                    table.insert(s, {
                        ["t"] = "r",
                        ["v"] = p and (",\n" .. string.rep(t, child_t)) or ",",
                        ["d"] = child_t
                    })
                end
            end
            table.insert(s, {
                ["t"] = "r",
                ["v"] = p and ("{\n" .. string.rep(t, child_t)) or "{",
                ["d"] = child_t
            })
            goto next_iteration
        end
        r = r .. "\"[object Lua[\\\"" .. ct .. "\\\"]]\""
        ::next_iteration::
    end
    return r
end

XL.escapeString = escapeString
XL.is_none = is_none
XL.is_bool = is_bool
XL.is_string = is_string
XL.is_int = is_int
XL.is_float = is_float
XL.is_closure = is_closure
XL.is_list = is_list
XL.is_dict = is_dict
XL.dict_to_list = dict_to_list
XL.json_stringify = json_stringify

return XL
