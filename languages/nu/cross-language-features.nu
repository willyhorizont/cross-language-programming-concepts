# 1. support function as value
let say_hello = {|callback_function|
    print "hello"
    do $callback_function
}
do $say_hello {||
    print "how are you?"
}
let multiply = {|a| {|b| $a * $b}}
let multiply_by_two = do $multiply 2
print $"do $multiply_by_two 10: (do $multiply_by_two 10)"

# 2. support dynamic-typed value, or has workaround
let some_python_like_list = [
    null,
    true,
    false,
    "foo",
    123,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    {foo:"bar"},
    {|a, b| ($a * $b)},
]
print $"$some_python_like_list: ($some_python_like_list | to json --serialize --indent 4)"
let some_python_like_dict = {
    some_null:null,
    some_boolean_true:true,
    some_boolean_false:false,
    some_string:"foo",
    some_int_positive:123,
    some_int_negative:-123,
    some_float_positive:123.789,
    some_float_negative:-123.789,
    some_python_like_list:[1, 2, 3],
    some_python_like_dict:{foo:"bar"},
    some_function:{|a, b| ($a * $b)},
}
print $"$some_python_like_dict: ($some_python_like_dict | to json --serialize --indent 4)"
