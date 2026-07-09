# 1. support closure as value, or has workaround
var say-hello = {|callback-function|
    echo "hello"
    $callback-function
}
$say-hello {||
    echo "wold"
}
var multiply = {|a| put {|b| put (* $a $b) }}
var multiply-by-two = ($multiply 2)
echo "$multiply-by-two 10: "($multiply-by-two 10)""

# 2. support dynamic-typed value, or has workaround
var some-python-like-list = [
    $nil
    $true
    $false
    "foo"
    123
    -123
    123.789
    -123.789
    [1 2 3]
    [&foo=bar]
    {|a b| put (* $a $b)}
]
echo "some-python-like-list: "(to-string $some-python-like-list)""
var some-python-like-dict = [
    &some-null=$nil
    &some-boolean-true=$true
    &some-boolean-false=$false
    &some-string="foo"
    &some-int-positive=123
    &some-int-negative=-123
    &some-float-positive=123.789
    &some-float-negative=-123.789
    &some-python-like-list=[1 2 3]
    &some-python-like-dict=[&foo=bar]
    &some-function={|a b| put (* $a $b)}
]
echo "some-python-like-dict: "(to-string $some-python-like-dict)""
