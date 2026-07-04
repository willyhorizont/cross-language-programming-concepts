local xl = require("runtimes.lua.willyhorizont.runtime")

--[[ 
1. support closure as value, or has workaround
]]
local say_hello = function (callback_function)
    callback_function()
    print("hello")
end
say_hello(function ()
    print("world")
end)
local create_multiplier = function (aa) return function (bb) return (aa * bb) end end
local multiply_by_two = create_multiplier(2)
print("multiply_by_two(10): " .. multiply_by_two(10))
local multiply_by_eight = create_multiplier(8)
print("multiply_by_eight(4): " .. multiply_by_eight(4))
print("multiply_by_two(8): " .. multiply_by_two(8))

--[[ 
2. support dynamic-typed value, or has workaround
]]
local xl_list = {
    nil,
    true,
    false,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    {1, 2, 3},
    { ["foo"] = "bar" },
    function (aa, bb) return (aa * bb) end,
}
print("xl_list: " .. xl.json_stringify(xl_list))
print("xl_list: " .. xl.json_stringify(xl_list, { ["pretty"] = true }))
local xl_dict = {
    ["xl_none"] = nil,
    ["xl_bool_true"] = true,
    ["xl_bool_false"] = false,
    ["xl_string"] = "foo",
    ["xl_int_positive"] = 0,
    ["xl_int_negative"] = -123,
    ["xl_float_positive"] = 123.789,
    ["xl_float_negative"] = -123.789,
    ["xl_list"] = {1, 2, 3},
    ["xl_dict"] = { ["foo"] = "bar" },
    ["xl_closure"] = function (aa, bb) return (aa * bb) end,
}
print("xl_dict: " .. xl.json_stringify(xl_dict))
print("xl_dict: " .. xl.json_stringify(xl_dict, { ["pretty"] = true }))
