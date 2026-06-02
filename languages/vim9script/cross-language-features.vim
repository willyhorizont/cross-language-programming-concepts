vim9script

# 1. support function as value
var SayHello = (Callback) => {
    echomsg "hello\n"
    Callback()
}
SayHello(() => {
    echomsg "wold"
})
var Multiply = (a) => (b) => (a * b)
var MultiplyByTwo = Multiply(2)
echomsg $"MultiplyByTwo(10): {MultiplyByTwo(10)}"

var SomePythonLikeList = [
    null,
    true,
    false,
    "foo",
    123,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    {foo: "bar"},
    (a, b) => (a * b)
]
# echomsg $"SomePythonLikeList: {json_encode(SomePythonLikeList)}"

# 2. support dynamic-typed value, or has workaround
var SomePythonLikeDict: dict<any> = {
    some_null: null,
    some_boolean_true: true,
    some_boolean_false: false,
    some_string: "foo",
    some_int_positive: 123,
    some_int_negative: -123,
    some_float_positive: 123.789,
    some_float_negative: -123.789,
    SomePythonLikeList: [1, 2, 3],
    some_python_like_dict: {foo: "bar"},
    some_function: (a, b) => (a * b)
}
# echomsg $"SomePythonLikeDict: {json_encode(SomePythonLikeDict)}"
