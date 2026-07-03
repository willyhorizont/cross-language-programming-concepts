<?php
require_once __DIR__ . '/../../runtimes/php/willyhorizont/runtime.php';
use Runtimes\Php\WillyHorizont\Runtime;

/*
1. support closure as value, or has workaround
*/
$say_hello = function ($callback_function) {
    echo "hello" . PHP_EOL;
    $callback_function();
};
$say_hello(function () {
    echo "world" . PHP_EOL;
});
$create_multiplier = fn ($aa) => fn ($bb) => ($aa * $bb);
$multiply_by_two = $create_multiplier(2);
echo "multiply_by_two(10): " . $multiply_by_two(10) . PHP_EOL;
$multiply_by_eight = $create_multiplier(8);
echo "multiply_by_eight(4): " . $multiply_by_eight(4) . PHP_EOL;
echo "multiply_by_two(8): " . $multiply_by_two(8) . PHP_EOL;

/*
2. support dynamic-typed value, or has workaround
*/
$xl_list = [
    null,
    true,
    false,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    ["foo" => "bar"],
    fn ($aa, $bb) => ($aa * $bb),
];
echo "xl_list" . Runtime::json_stringify($xl_list) . PHP_EOL;
echo "xl_list" . Runtime::json_stringify($xl_list, ["pretty" => true]) . PHP_EOL;
$xl_dict = [
    "xl_none" => null,
    "xl_bool_true" => true,
    "xl_bool_false" => false,
    "xl_string" => "foo",
    "xl_int_positive" => 0,
    "xl_int_negative" => -123,
    "xl_float_positive" => 123.789,
    "xl_float_negative" => -123.789,
    "xl_list" => [1, 2, 3],
    "xl_dict" => ["foo" => "bar"],
    "xl_closure" => fn ($aa, $bb) => ($aa * $bb),
];
echo "xl_dict" . Runtime::json_stringify($xl_dict) . PHP_EOL;
echo "xl_dict" . Runtime::json_stringify($xl_dict, ["pretty" => true]) . PHP_EOL;
