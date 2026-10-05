#include <stdio.h>
#include <stdlib.h>
#include "../../runtimes/c/willyhorizont/runtime/xl.h"

int main(int argc, char *argv[]) {
    /*
    1. support lambda as value, or has workaround
    */
    Xl* say_hello = xl.init_lambda({
        Xl* itr = xl.iter(vararg);
        Xl* callback = xl.next(itr);
        printf("hello\n");
        xl.free(xl.call(callback, xl.NONE));
        xl.free(itr);
        xl.free(vararg);
        return xl.NONE;
    }, NULL);
    xl.call(say_hello, xl.init_lambda({
        printf("world\n");
        return xl.NONE;
    }, NULL));
    xl.free(say_hello);
    Xl* create_multiplier = xl.init_lambda({
        Xl* itr = xl.iter(vararg);
        Xl* aa = xl.next(itr);
        auto aa_ctx = aa->int_value;
        xl.free(itr);
        xl.free(vararg);
        return xl.init_lambda({
            Xl* itr = xl.iter(vararg);
            Xl* bb = xl.next(itr);
            Xl* aa = xl.get(ctx_ref, "aa");
            Xl* rr = xl.init_int(aa->int_value * bb->int_value);
            xl.free(itr);
            xl.free(vararg);
            return rr;
        }, xl.init_dict(xl.init_pair("aa", xl.init_int(aa_ctx))));
    }, NULL);
    Xl* multiply_by_two = xl.call(create_multiplier, xl.init_int(2));
    xl.print("multiply_by_two(10): ", xl.to_string(xl.call(multiply_by_two, xl.init_int(10))));
    Xl* multiply_by_eight = xl.call(create_multiplier, xl.init_int(8));
    xl.print("multiply_by_eight(4): ", xl.to_string(xl.call(multiply_by_eight, xl.init_int(4))));
    xl.print("multiply_by_two(8): ", xl.to_string(xl.call(multiply_by_two, xl.init_int(8))));
    xl.free(multiply_by_eight);
    xl.free(multiply_by_two);
    xl.free(create_multiplier);
    
    /*
    2. support dynamic-typed value, or has workaround
    */
    Xl* xl_list = xl.init_list(
        xl.NONE,
        xl.TRUE,
        xl.FALSE,
        xl.init_string("foo"),
        xl.init_int(0),
        xl.init_int(-123),
        xl.init_float(123.789),
        xl.init_float(-123.789),
        xl.init_list(xl.init_int(1), xl.init_int(2), xl.init_int(3)),
        xl.init_dict(xl.init_pair("foo", xl.init_string("bar"))),
        xl.init_lambda({
            Xl* itr = xl.iter(vararg);
            Xl* aa = xl.next(itr);
            Xl* bb = xl.next(itr);
            Xl* rr = xl.init_int(aa->int_value * bb->int_value);
            xl.free(itr);
            xl.free(vararg);
            return rr;
        }, NULL)
    );
    xl.print("xl_list: ", xl.json_stringify(xl_list));
    xl.print("xl_list: ", xl.json_stringify(xl_list, .pretty = true));
    xl.free(xl_list);
    Xl* xl_dict = xl.init_dict(
        xl.init_pair("xl_none", xl.NONE),
        xl.init_pair("xl_bool_true", xl.TRUE),
        xl.init_pair("xl_bool_false", xl.FALSE),
        xl.init_pair("xl_string", xl.init_string("foo")),
        xl.init_pair("xl_int_positive", xl.init_int(0)),
        xl.init_pair("xl_int_negative", xl.init_int(-123)),
        xl.init_pair("xl_float_positive", xl.init_float(123.789)),
        xl.init_pair("xl_float_negative", xl.init_float(-123.789)),
        xl.init_pair("xl_list", xl.init_list(xl.init_int(1), xl.init_int(2), xl.init_int(3))),
        xl.init_pair("xl_dict", xl.init_dict(xl.init_pair("foo", xl.init_string("bar")))),
        xl.init_pair("xl_lambda", xl.init_lambda({
            Xl* itr = xl.iter(vararg);
            Xl* aa = xl.next(itr);
            Xl* bb = xl.next(itr);
            Xl* rr = xl.init_int(aa->int_value * bb->int_value);
            xl.free(itr);
            xl.free(vararg);
            return rr;
        }, NULL))
    );
    xl.print("xl_dict: ", xl.json_stringify(xl_dict));
    xl.print("xl_dict: ", xl.json_stringify(xl_dict, .pretty = true));
    xl.free(xl_dict);
    
    return 0;
}
