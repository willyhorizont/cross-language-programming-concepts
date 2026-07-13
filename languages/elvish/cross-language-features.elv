# 1. support closure as value, or has workaround
var say-hello = {|callback-function|
    echo "hello"
    $callback-function
}
$say-hello {||
    echo "world"
}
var create-multiplier = {|a| put {|b| put (* $a $b) }}
var multiply-by-two = ($create-multiplier 2)
echo "multiply_by_two(10): "($multiply-by-two 10)""
var multiply-by-eight = ($create-multiplier 8)
echo "multiply_by_eight(4): "($multiply-by-eight 4)""
echo "multiply_by_two(8): "($multiply-by-two 8)""

# 2. support dynamic-typed value, or has workaround
var xl-list = [
    $nil
    $true
    $false
    "foo"
    0
    -123
    123.789
    -123.789
    [1 2 3]
    [&"foo"="bar"]
    {|a b| put (* $a $b)}
]
echo "xl-list: "(to-string $xl-list)""
var xl-dict = [
    &"xl_null"=$nil
    &"xl_bool"=$true
    &"xl_bool"=$false
    &"xl_string"="foo"
    &"xl_int_positive"=0
    &"xl_int_negitive"=-123
    &"xl_float_positive"=123.789
    &"xl_float_negitive"=-123.789
    &"xl_list"=[1 2 3]
    &"xl_dict"=[&"foo"="bar"]
    &"xl_closure"={|a b| put (* $a $b)}
]
echo "xl-dict: "(to-string $xl-dict)""
