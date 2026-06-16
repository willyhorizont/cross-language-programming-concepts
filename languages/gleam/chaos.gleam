import gleam/dynamic.{type Dynamic}
import gleam/io
import gleam/string

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
    let some_python_like_list: List(Dynamic) = [
        dynamic.nil(),
        dynamic.bool(True),
        dynamic.bool(False),
        dynamic.string("foo"),
        dynamic.int(0),
        dynamic.int(-123),
        dynamic.float(123.789),
        dynamic.float(-123.789),
        dynamic.list([dynamic.int(1), dynamic.int(2), dynamic.int(3)]),
        dynamic.list([dynamic.list([dynamic.string("foo"), dynamic.string("bar")])]),
        // dynamic.function(fn(a: Int, b: Int) { a * b }), no dynamic.function() :(
    ]
    io.println("some_python_like_list: " <> string.inspect(some_python_like_list))
    let some_python_like_dict: List(Dynamic) = [
        dynamic.list([dynamic.string("some_null"), dynamic.nil()]),
        dynamic.list([dynamic.string("some_boolean_true"), dynamic.bool(True)]),
        dynamic.list([dynamic.string("some_boolean_false"), dynamic.bool(False)]),
        dynamic.list([dynamic.string("some_string"), dynamic.string("foo")]),
        dynamic.list([dynamic.string("some_int_positive"), dynamic.int(0)]),
        dynamic.list([dynamic.string("some_int_negative"), dynamic.int(-123)]),
        dynamic.list([dynamic.string("some_float_positive"), dynamic.float(123.789)]),
        dynamic.list([dynamic.string("some_float_negative"), dynamic.float(-123.789)]),
        dynamic.list([dynamic.string("some_python_like_list"), dynamic.list([dynamic.int(1), dynamic.int(2), dynamic.int(3)])]),
        dynamic.list([dynamic.string("some_python_like_dict"), dynamic.list([dynamic.list([dynamic.string("foo"), dynamic.string("bar")])])]),
        // dynamic.list([dynamic.string("some_function"), dynamic.function(fn(a: Int, b: Int) { a * b })]), no dynamic.function() :(
    ]
    io.println("some_python_like_dict: " <> string.inspect(some_python_like_dict))
}
