use ../../runtimes/nu/willyhorizont/runtime/xl.nu

# 1. support closure as value, or has workaround
let say_hello = { |callback_function|
    print "hello"
    do $callback_function
}
do $say_hello { ||
    print "world"
}
let create_multiplier = { |aa| { |bb| $aa * $bb } }
let multiply_by_two = (do $create_multiplier 2)
print $"multiply_by_two\(10): (do $multiply_by_two 10)"
let multiply_by_eight = (do $create_multiplier 8)
print $"multiply_by_eight\(4): (do $multiply_by_eight 4)"
print $"multiply_by_two\(8): (do $multiply_by_two 8)"

# 2. support dynamic-typed value, or has workaround
let xl_list = [
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
    { |aa, bb| $aa * $bb },
]
print $"xl_list: (xl json-stringify $xl_list)"
print $"xl_list: (xl json-stringify $xl_list --pretty)"
let xl_dict = {
    "xl_null": null,
    "xl_bool_true": true,
    "xl_bool_false": false,
    "xl_string": "foo",
    "xl_int_positive": 0,
    "xl_int_negative": -123,
    "xl_float_positive": 123.789,
    "xl_float_negative": -123.789,
    "xl_list": [1, 2, 3],
    "xl_dict": { "foo": "bar" },
    "xl_closure": { |aa, bb| $aa * $bb },
}
print $"xl_dict: (xl json-stringify $xl_dict)"
print $"xl_dict: (xl json-stringify $xl_dict --pretty)"
