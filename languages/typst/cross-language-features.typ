#import "/runtimes/typst/willyhorizont/runtime.typ": *
#show: setup-command-prompt
#{
/*
1. support function as value
*/
let say-hello = (callback-function) => {
    print-command("hello")
    callback-function()
}
say-hello(() => {
    print-command("world")
})
let multiply = (a) => (b) => (a * b)
let multiply-by-two = multiply(2)
print-command(to-string([multiply-by-two(10): #multiply-by-two(10)]))
let multiply-by-eight = multiply(8)
print-command(to-string([multiply-by-eight(4): #multiply-by-eight(4)]))
print-command(to-string([multiply-by-two(8): #multiply-by-two(8)]))

/*
2. support dynamic-typed value, or has workaround
*/
let some-python-like-list = (
    none,
    true,
    false,
    "foo",
    123,
    -123,
    123.789,
    -123.789,
    (1, 2, 3),
    ("foo": "bar"),
    (a, b) => (a * b),
)
print-command(to-string([some-python-like-list: #some-python-like-list]))
let some-python-like-dict = (
    ("some_null": none),
    ("some_boolean_true": true),
    ("some_boolean_false": false),
    ("some_string": "foo"),
    ("some_int_positive": 123),
    ("some_int_negative": -123),
    ("some_float_positive": 123.789),
    ("some_float_negative": -123.789),
    ("some_python_like_list": (1, 2, 3)),
    ("some_python_like_dict": ("foo": "bar")),
    ("some_function": (a, b) => (a * b)),
)
print-command(to-string([some-python-like-dict: #some-python-like-dict]))
}
