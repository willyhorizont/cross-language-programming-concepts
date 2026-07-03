local XL = {}

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

local function get_lua_table_properties(t)
    local ds = 0
    local ll = 0
    local has_k_no_int = false
    for k, _ in pairs(t) do
        ds = ds + 1
        if type(k) == "number" and k >= 1 and math.floor(k) == k then
            if k > ll then ll = k end
        else
            has_k_no_int = true
        end
    end
    return ds, ll, has_k_no_int
end

local is_list = function (a)
    if type(a) ~= "table" then return false end
    local ds, ll, has_k_no_int = get_lua_table_properties(a)
    if ds == 0 then return true end
    if has_k_no_int then return false end
    return true
end

local is_dict = function (a)
    if type(a) ~= "table" then return false end
    local ds, ll = get_lua_table_properties(a)
    if ds == 0 then return false end
    if ll == ds then return false end
    for k, _ in pairs(a) do
        if type(k) ~= "string" then return false end
    end
    return true
end

function dict_to_list(d)
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
        local v = c["v"]
        if c["t"] == "r" then
            r = r .. v
            goto next_iteration
        end
        local cur_t = c["d"]
        if v == nil then
            r = r .. "null"
            goto next_iteration
        end
        if type(v) == "boolean" then
            r = r .. (v and "true" or "false")
            goto next_iteration
        end
        if type(v) == "string" then
            r = r .. "\"" .. v .. "\""
            goto next_iteration
        end
        if type(v) == "number" then
            r = r .. tostring(v)
            goto next_iteration
        end
        if type(v) == "function" then
            r = r .. "\"[object Function]\""
            goto next_iteration
        end
        if is_list(v) then
            local _, lv = get_lua_table_properties(v)
            if lv == 0 then
                r = r .. "[]"
                goto next_iteration
            end
            local child_t = cur_t + 1
            table.insert(s, {
                ["t"] = "r",
                ["v"] = p and ("\n" .. string.rep(t, cur_t) .. "]") or "]",
                ["d"] = cur_t
            })
            for i = lv, 1, -1 do
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
        if is_dict(v) then
            local de = dict_to_list(v)
            local child_t = cur_t + 1
            table.insert(s, {
                ["t"] = "r",
                ["v"] = p and ("\n" .. string.rep(t, cur_t) .. "}") or "}",
                ["d"] = cur_t
            })
            for i = #de, 1, -1 do
                local dk, dv = table.unpack(de[i])
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
        r = r .. "\"[object Lua[\\\"" .. type(v) .. "\\\"]]\""
        ::next_iteration::
    end
    return r
end

XL.json_stringify = json_stringify

return XL
