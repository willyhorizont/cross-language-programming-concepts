import gleam/io
import gleam/string

pub type Any {
    PyNone
    PyBool(Bool)
    JsString(String)
    JsInt(Int)
    JsFloat(Float)
    PyList(List(Any))
    PyDict(List(#(String, Any)))
    JsFunction(fn(List(Any)) -> Any)
}

pub fn main() {
    // 1. Support function as value
    let say_hello = fn(callback_function: fn() -> Nil) {
        io.print("hello\n")
        callback_function()
    }
    say_hello(fn() { io.print("world\n") })
    let create_multiplier = fn(a: Int) {
        fn(b: Int) {
            a * b
        }
    }
    let multiply_by_two = create_multiplier(2)
    io.println("multiply_by_two.(10): " <> string.inspect(multiply_by_two(10)))
    let multiply_by_eight = create_multiplier(8)
    io.println("multiply_by_eight.(4): " <> string.inspect(multiply_by_eight(4)))
    io.println("multiply_by_two.(8): " <> string.inspect(multiply_by_two(8)))

    // 2. Support dynamic-typed value
    let some_python_like_list = PyList([
        PyNone,
        PyBool(True),
        PyBool(False),
        JsString("foo"),
        JsInt(0),
        JsInt(-123),
        JsFloat(123.789),
        JsFloat(-123.789),
        PyList([JsInt(1), JsInt(2), JsInt(3)]),
        PyDict([#("foo", JsString("bar"))]),
        JsFunction(fn(variadic_arguments) {
            case variadic_arguments {
                [JsInt(a), JsInt(b), ..] -> JsInt(a * b)
                _ -> PyNone
            }
        }),
    ])
    io.println("some_python_like_list: " <> string.inspect(some_python_like_list))
    let some_python_like_dict = PyDict([
        #("some_null", PyNone),
        #("some_boolean_true", PyBool(True)),
        #("some_boolean_false", PyBool(False)),
        #("some_string", JsString("foo")),
        #("some_int_positive", JsInt(0)),
        #("some_int_negative", JsInt(-123)),
        #("some_float_positive", JsFloat(123.789)),
        #("some_float_negative", JsFloat(-123.789)),
        #("some_python_like_list", PyList([JsInt(1), JsInt(2), JsInt(3)])),
        #("some_python_like_dict", PyDict([#("foo", JsString("bar"))])),
        #("some_function", JsFunction(fn(variadic_arguments) {
            case variadic_arguments {
                [JsInt(a), JsInt(b), ..] -> JsInt(a * b)
                _ -> PyNone
            }
        })),
    ])
    io.println("some_python_like_dict: " <> string.inspect(some_python_like_dict))
}
