int main() {
    mixed xl = compile_file(combine_path(__DIR__, "../../runtimes/pike/willyhorizont/runtime/xl.pike"))();

    /*
    1. support lambda as value, or has workaround
    */
    mixed say_hello = lambda(mixed callback_function) {
        xl->writeln("hello");
        callback_function();
    };
    say_hello(lambda() {
        xl->writeln("world");
    });
    mixed create_multiplier = lambda(mixed aa) {
        return lambda(mixed bb) {
            return aa * bb;
        };
    };
    mixed multiply_by_two = create_multiplier(2);
    xl->writeln("multiply_by_two(10): ", multiply_by_two(10));
    mixed multiply_by_eight = create_multiplier(8);
    xl->writeln("multiply_by_eight(4): ", multiply_by_eight(4));
    xl->writeln("multiply_by_two(8): ", multiply_by_two(8));

    /*
    2. support dynamic-typed value, or has workaround
    */
    mixed xl_list = ({
        0, // null
        1, // true
        0, // false
        "foo",
        0, // 0
        -123,
        123.789,
        -123.789,
        ({ 1, 2, 3}),
        ([ "foo" : "bar" ]),
        lambda(mixed aa, mixed bb) {
            return aa * bb;
        },
    });
    xl->writeln("xl_list: ", xl->json_stringify(xl_list));
    xl->writeln("xl_list: ", xl->json_stringify(xl_list, ([ "pretty" : 1 ])));
    mixed xl_dict = ([
        "xl_none": 0, // null
        "xl_bool_true": 1, // true
        "xl_bool_false": 0, // false
        "xl_string": "foo",
        "xl_int_positive": 0, // 0
        "xl_int_negative": -123,
        "xl_float_positive": 123.789,
        "xl_float_negative": -123.789,
        "xl_list": ({ 1, 2, 3}),
        "xl_dict": ([ "foo" : "bar" ]),
        "xl_lambda": lambda(mixed aa, mixed bb) {
            return aa * bb;
        },
    ]);
    xl->writeln("xl_dict: ", xl->json_stringify(xl_dict));
    xl->writeln("xl_dict: ", xl->json_stringify(xl_dict, ([ "pretty" : 1 ])));
    return 0;
}
