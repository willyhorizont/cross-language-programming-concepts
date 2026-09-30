vim9script

import "../../runtimes/vimscript/willyhorizont/runtime/xl.vim"

# // ' -- 1. support lambda as value, or has workaround
var SayHello = (Callback) => {
    xl.Echoln("hello")
    Callback()
}
SayHello(() => {
    xl.Echoln("world")
})
var CreateMultiplier = (aa) => (bb) => aa * bb
var MultiplyByTwo = CreateMultiplier(2)
xl.Echoln($"multiply_by_two(10): {MultiplyByTwo(10)}")
var MultiplyByEight = CreateMultiplier(8)
xl.Echoln($"multiply_by_eight(4): {MultiplyByEight(4)}")
xl.Echoln($"multiply_by_two(8): {MultiplyByTwo(8)}")

# // ' -- 2. support dynamic-typed value, or has workaround
var XlList = [
    null,
    true,
    false,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    {"foo": "bar"},
    (aa, bb) => aa * bb,
]
xl.Echoln($"xl_list: {xl.JsonStringify(XlList)}")
xl.Echoln($"xl_list: {xl.JsonStringify(XlList, {"pretty": true})}")
var XlDict = {
    "xl_none": null,
    "xl_bool_true": true,
    "xl_bool_false": false,
    "xl_string": "foo",
    "xl_int_positive": 0,
    "xl_int_negative": -123,
    "xl_float_positive": 123.789,
    "xl_float_negative": -123.789,
    "xl_list": [1, 2, 3],
    "xl_dict": {"foo": "bar"},
    "xl_lambda": (aa, bb) => aa * bb,
}
xl.Echoln($"xl_dict: {xl.JsonStringify(XlDict)}")
xl.Echoln($"xl_dict: {xl.JsonStringify(XlDict, {"pretty": true})}")
