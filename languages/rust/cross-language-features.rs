use std::fmt;

pub enum Any {
    PyNone,
    PyBool(bool),
    JsString(String),
    JsInt(i32),
    JsFloat(f64),
    PyList(Vec<Any>),
    PyDict(Vec<(String, Any)>),
    JsFunction(fn(Vec<Any>) -> Any),
}

impl fmt::Debug for Any {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Any::PyNone => write!(f, "PyNone"),
            Any::PyBool(b) => write!(f, "PyBool({})", b),
            Any::JsString(s) => write!(f, "JsString({:?})", s),
            Any::JsInt(i) => write!(f, "JsInt({})", i),
            Any::JsFloat(fl) => write!(f, "JsFloat({})", fl),
            Any::PyList(l) => write!(f, "PyList({:?})", l),
            Any::PyDict(d) => write!(f, "PyDict({:?})", d),
            Any::JsFunction(_) => write!(f, "JsFunction(<fn>)"),
        }
    }
}

fn main() {
    // support function as value
    let say_hello = |callback_function: fn()| {
        println!("hello");
        callback_function();
    };
    say_hello(|| println!("world"));
    let create_multiplier = |a: i32| move |b: i32| a * b;
    let multiply_by_two = create_multiplier(2);
    println!("multiply_by_two(10): {}", multiply_by_two(10));
    let multiply_by_eight = create_multiplier(8);
    println!("multiply_by_eight(4): {}", multiply_by_eight(4));
    println!("multiply_by_two(8): {}", multiply_by_two(8));

    // support dynamic-typed value, or has workaround
    let some_python_like_list = Any::PyList(vec![
        Any::PyNone,
        Any::PyBool(true),
        Any::PyBool(false),
        Any::JsString(String::from("foo")),
        Any::JsInt(0),
        Any::JsInt(-123),
        Any::JsFloat(123.789),
        Any::JsFloat(-123.789),
        Any::PyList(vec![Any::JsInt(1), Any::JsInt(2), Any::JsInt(3)]),
        Any::PyList(vec![Any::PyList(vec![Any::JsString(String::from("foo")), Any::JsString(String::from("bar"))])]),
        Any::JsFunction(|variadic_arguments| {
            match variadic_arguments.as_slice() {
                [Any::JsInt(a), Any::JsInt(b), ..] => Any::JsInt(a * b),
                _ => Any::PyNone,
            }
        }),
    ]);
    println!("some_python_like_list: {:?}", some_python_like_list);
    let some_python_like_dict = Any::PyDict(vec![
        (String::from("some_null"), Any::PyNone),
        (String::from("some_boolean_true"), Any::PyBool(true)),
        (String::from("some_boolean_false"), Any::PyBool(false)),
        (String::from("some_string"), Any::JsString(String::from("foo"))),
        (String::from("some_int_positive"), Any::JsInt(0)),
        (String::from("some_int_negative"), Any::JsInt(-123)),
        (String::from("some_float_positive"), Any::JsFloat(123.789)),
        (String::from("some_float_negative"), Any::JsFloat(-123.789)),
        (String::from("some_python_like_list"), Any::PyList(vec![Any::JsInt(1), Any::JsInt(2), Any::JsInt(3)])),
        (String::from("some_python_like_dict"), Any::PyList(vec![Any::PyList(vec![Any::JsString(String::from("foo")), Any::JsString(String::from("bar"))])])),
        (String::from("some_function"), Any::JsFunction(|variadic_arguments| {
            match variadic_arguments.as_slice() {
                [Any::JsInt(a), Any::JsInt(b), ..] => Any::JsInt(a * b),
                _ => Any::PyNone,
            }
        })),
    ]);
    println!("some_python_like_dict: {:?}", some_python_like_dict);
}
