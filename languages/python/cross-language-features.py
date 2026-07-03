from runtimes.python.willyhorizont.runtime import json_stringify

# 1. support closure as value, or has workaround
say_hello = lambda callback_function: [
    print("hello"),
    callback_function(),
][-1]
say_hello(lambda: print("wold"))
create_multiplier = lambda aa: lambda bb: (aa * bb)
multiply_by_two = create_multiplier(2)
print(f"multiply_by_two(10): {multiply_by_two(10)}")
multiply_by_eight = create_multiplier(8)
print(f"multiply_by_eight(4): {multiply_by_eight(4)}")
print(f"multiply_by_two(8): {multiply_by_two(8)}")

# 2. support dynamic-typed value, or has workaround
xl_list = [
    None,
    True,
    False,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    {"foo":"bar"},
    lambda aa, bb: (aa * bb),
]
print(f"xl_list: {json_stringify(xl_list)}")
print(f"xl_list: {json_stringify(xl_list, pretty=True)}")
xl_dict = {
    "xl_none": None,
    "xl_bool_true": True,
    "xl_bool_false": False,
    "xl_string": "foo",
    "xl_int_positive": 0,
    "xl_int_negative": -123,
    "xl_float_positive": 123.789,
    "xl_float_negative": -123.789,
    "xl_list": [1, 2, 3],
    "xl_dict": {"foo":"bar"},
    "xl_closure": lambda aa, bb: (aa * bb),
}
print(f"xl_dict: {json_stringify(xl_dict)}")
print(f"xl_dict: {json_stringify(xl_dict, pretty=True)}")
