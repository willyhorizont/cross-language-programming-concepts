use v6.d;
EVALFILE $*PROGRAM.IO.parent.add("../../runtimes/raku/willyhorizont/runtime/xl.raku");

#`(
1. support closure as value, or has workaround
)

my $say-hello = sub ($callback-function) {
    print("hello\n");
    $callback-function();
};
$say-hello(sub () {
    print("world\n");
});
my $create-multiplier = sub ($aa) {
    return sub ($bb) {
        return $aa * $bb
    };
};
my $multiply-by-two = $create-multiplier(2);
print("multiply_by_two(10): {$multiply-by-two(10)}\n");
my $multiply-by-eight = $create-multiplier(8);
print("multiply_by_eight(4): {$multiply-by-eight(4)}\n");
print("multiply_by_two(8): {$multiply-by-two(8)}\n");

#`(
2. support dynamic-typed value, or has workaround
)
my $xl-list = [
    Nil,
    True,
    False,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    {"foo" => "bar"},
    sub ($a, $b) {
        return ($a * $b);
    },
];
print("xl_list: {xl::json-stringify($xl-list)}\n");
print("xl_list: {xl::json-stringify($xl-list, pretty => True)}\n");
my $xl-dict = {
    "xl_none" => Nil,
    "xl_bool_true" => True,
    "xl_bool_false" => False,
    "xl_string" => "foo",
    "xl_int_positive" => 0,
    "xl_int_negative" => -123,
    "xl_float_positive" => 123.789,
    "xl_float_negative" => -123.789,
    "xl_list" => [1, 2, 3],
    "xl_dict" => {"foo" => "bar"},
    "xl_closure" => sub ($a, $b) {
        return ($a * $b);
    },
};
print("xl_dict: {xl::json-stringify($xl-dict)}\n");
print("xl_dict: {xl::json-stringify($xl-dict, pretty => True)}\n");
