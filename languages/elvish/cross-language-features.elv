use ../../runtimes/elvish/willyhorizont/runtime/xl

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
echo "multiply_by_two(10):" ($multiply-by-two 10)
var multiply-by-eight = ($create-multiplier 8)
echo "multiply_by_eight(4):" ($multiply-by-eight 4)
echo "multiply_by_two(8):" ($multiply-by-two 8)

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
echo "xl_list:" ($xl:json-stringify $xl-list)
echo "xl_list:" ($xl:json-stringify $xl-list &pretty=$true)
var xl-dict = [
    &"xl_none"=$nil
    &"xl_bool_true"=$true
    &"xl_bool_false"=$false
    &"xl_string"="foo"
    &"xl_int_positive"=0
    &"xl_int_negative"=-123
    &"xl_float_positive"=123.789
    &"xl_float_negative"=-123.789
    &"xl_list"=[1 2 3]
    &"xl_dict"=[&"foo"="bar"]
    &"xl_closure"={|a b| put (* $a $b)}
]
echo "xl_dict:" ($xl:json-stringify $xl-dict)
echo "xl_dict:" ($xl:json-stringify $xl-dict &pretty=$true)
