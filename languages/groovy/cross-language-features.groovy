import runtimes.groovy.willyhorizont.Runtime

/*
1. support closure as value
*/
def sayHello = { callbackFunction ->
    println("hello")
    callbackFunction()
}
sayHello({ ->
    println("world")
})
def createMultiplier = { aa -> { bb -> (aa * bb) } }
def multiplyByTwo = createMultiplier(2)
println("multiply_by_two(10): ${multiplyByTwo(10)}")
def multiplyByEight = createMultiplier(8)
println("multiply_by_eight(4): ${multiplyByEight(4)}")
println("multiply_by_two(8): ${multiplyByTwo(8)}")

/*
2. support dynamic-typed value, or has workaround
*/
def xlList = [
    null,
    true,
    false,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    [ "foo": "bar" ],
    { aa, bb -> (aa * bb) }
]
println("xl_list: ${Runtime.jsonStringify(xlList)}")
println("xl_list: ${Runtime.jsonStringify(xlList, [pretty: true])}")
def xlDict = [
    "xl_none": null,
    "xl_bool_true": true,
    "xl_bool_false": false,
    "xl_string": "foo",
    "xl_int_positive": 0,
    "xl_int_negative": -123,
    "xl_float_positive": 123.789,
    "xl_float_negative": -123.789,
    "xl_list": [1, 2, 3],
    "xl_dict": [ "foo": "bar" ],
    "xl_closure": { aa, bb -> (aa * bb) }
]
println("xl_dict: ${Runtime.jsonStringify(xlDict)}")
println("xl_dict: ${Runtime.jsonStringify(xlDict, [pretty: true])}")
