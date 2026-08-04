int main() {
    mixed xl = compile_file(combine_path(__DIR__, "../../runtimes/pike/willyhorizont/runtime/xl.pike"))();

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

    mixed xl_list = ({
        UNDEFINED,
        1,
        0,
        "foo",
        0,
        -123,
        123.789,
        -123.789,
        ({ 1, 2, 3}),
        ([ "foo" : "bar" ]),
        lambda(mixed aa, mixed bb) {
            return aa * bb;
        },
    });
    mixed xl_dict = ([
        "xl_none": UNDEFINED,
        "xl_bool_true": 1,
        "xl_bool_false": 0,
        "xl_string": "foo",
        "xl_int_positive": 0,
        "xl_int_negative": -123,
        "xl_float_positive": 123.789,
        "xl_float_negative": -123.789,
        "xl_list": ({ 1, 2, 3}),
        "xl_dict": ([ "foo" : "bar" ]),
        "xl_lambda": lambda(mixed aa, mixed bb) {
            return aa * bb;
        },
    ]);
    return 0;
}
