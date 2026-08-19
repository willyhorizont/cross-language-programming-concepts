import "../../runtimes/wren/willyhorizont/runtime/xl" for Xl

/*
# ' -- 1. support lambda as value, or has workaround
*/
var sayHello = Fn.new {|callback|
    System.print("hello")
    callback.call()
}
sayHello.call(Fn.new {
    System.print("world")
})
var createMultiplier = Fn.new {|aa| Fn.new {|bb| aa * bb }}
var multiplyByTwo = createMultiplier.call(2)
System.print("multiply_by_two(10): %(multiplyByTwo.call(10))")
var multiplyByEight = createMultiplier.call(8)
System.print("multiply_by_eight(4): %(multiplyByEight.call(4))")
System.print("multiply_by_two(8): %(multiplyByTwo.call(8))")

/*
# ' -- 2. support dynamic-typed value, or has workaround
*/
var xlList = [
    null,
    true,
    false,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    { "foo": "bar" },
    Fn.new {|aa, bb| aa * bb },
]
System.print("xl_list: %(Xl.jsonStringify([xlList]))")
System.print("xl_list: %(Xl.jsonStringify([xlList, { "pretty": true }]))")
var xlDict = {
    "xl_none": null,
    "xl_bool_true": true,
    "xl_bool_false": false,
    "xl_string": "foo",
    "xl_int_positive": 0,
    "xl_int_negative": -123,
    "xl_float_positive": 123.789,
    "xl_float_negative": -123.789,
    "xl_list": [1, 2, 3],
    "xl_dict": { "foo": "bar" },
    "xl_lambda": Fn.new {|aa, bb| aa * bb },
}
System.print("xl_dict: %(Xl.jsonStringify([xlDict]))")
System.print("xl_dict: %(Xl.jsonStringify([xlDict, { "pretty": true }]))")
