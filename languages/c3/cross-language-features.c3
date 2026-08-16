module main;

import std::io;
import willyhorizont::runtime::xl;

fn void main()
{
    /*
    1. support lambda as value, or has workaround
    */
    xl::Type* say_hello = xl::init_lambda(fn xl::Type* (xl::Type* ctx_ref, xl::Type* va)
    {
        defer xl::free_memory(va);
        xl::Type* itr = xl::iter(va);
        defer xl::free_memory(itr);
        xl::Type* callback_function = xl::next(itr);
        io::printn("hello");
        xl::free_memory(callback_function.call(xl::init_none()));
        return xl::init_none();
    });
    defer xl::free_memory(say_hello);
    xl::free_memory(say_hello.call(xl::init_lambda(fn xl::Type* (xl::Type* ctx_ref, xl::Type* va)
    {
        defer xl::free_memory(va);
        xl::Type* itr = xl::iter(va);
        defer xl::free_memory(itr);
        io::printn("world");
        return xl::init_none();
    })));
    xl::Type* create_multiplier = xl::init_lambda(fn xl::Type* (xl::Type* ctx_ref_aa, xl::Type* va_aa)
    {
        defer xl::free_memory(va_aa);
        xl::Type* itr_aa = xl::iter(va_aa);
        defer xl::free_memory(itr_aa);
        xl::Type* aa = xl::next(itr_aa);
        return xl::init_lambda(fn xl::Type* (xl::Type* ctx_ref_bb, xl::Type* va_bb)
        {
            defer xl::free_memory(va_bb);
            xl::Type* itr_bb = xl::iter(va_bb);
            defer xl::free_memory(itr_bb);
            xl::Type* bb = xl::next(itr_bb);
            xl::Type* aa = xl::get(ctx_ref_bb, "aa");
            return xl::init_int(aa.int_value * bb.int_value);
        }, xl::init_dict(
            { "aa", xl::init_int(aa.int_value) },
        ));
    });
    defer xl::free_memory(create_multiplier);
    xl::Type* multiply_by_two = create_multiplier.call(xl::init_int(2));
    defer xl::free_memory(multiply_by_two);
    xl::printn("multiply_by_two(10): ", xl::to_string(multiply_by_two.call(xl::init_int(10))));
    xl::Type* multiply_by_eight = create_multiplier.call(xl::init_int(8));
    defer xl::free_memory(multiply_by_eight);
    xl::printn("multiply_by_eight(4): ", xl::to_string(multiply_by_eight.call(xl::init_int(4))));
    xl::printn("multiply_by_two(8): ", xl::to_string(multiply_by_two.call(xl::init_int(8))));
    
    /*
    2. support dynamic-typed value, or has workaround
    */
    xl::Type* xl_list = xl::init_list(
        xl::init_none(),
        xl::init_bool(true),
        xl::init_bool(false),
        xl::init_string("foo"),
        xl::init_int(0),
        xl::init_int(-123),
        xl::init_float(123.789),
        xl::init_float(-123.789),
        xl::init_list(xl::init_int(1), xl::init_int(2), xl::init_int(3)),
        xl::init_dict({ "foo", xl::init_string("bar") }),
        xl::init_lambda(fn xl::Type* (xl::Type* ctx_ref, xl::Type* va)
        {
            defer xl::free_memory(va);
            xl::Type* itr = xl::iter(va);
            defer xl::free_memory(itr);
            xl::Type* aa = xl::next(itr);
            xl::Type* bb = xl::next(itr);
            return xl::init_int(aa.int_value * bb.int_value);
        }),
    );
    defer xl::free_memory(xl_list);
    xl::printn("xl_list: ", xl::json_stringify(xl_list));
    xl::printn("xl_list: ", xl::json_stringify(xl_list, pretty: true));
    xl::Type* xl_dict = xl::init_dict(
        { "xl_none", xl::init_none() },
        { "xl_bool_true", xl::init_bool(true) },
        { "xl_bool_false", xl::init_bool(false) },
        { "xl_string", xl::init_string("foo") },
        { "xl_int_positive", xl::init_int(0) },
        { "xl_int_negative", xl::init_int(-123) },
        { "xl_float_positive", xl::init_float(123.789) },
        { "xl_float_negative", xl::init_float(-123.789) },
        { "xl_list", xl::init_list(xl::init_int(1), xl::init_int(2), xl::init_int(3)) },
        { "xl_dict", xl::init_dict({ "foo", xl::init_string("bar") }) },
        { "xl_lambda", xl::init_lambda(fn xl::Type* (xl::Type* ctx_ref, xl::Type* va)
        {
            defer xl::free_memory(va);
            xl::Type* itr = xl::iter(va);
            defer xl::free_memory(itr);
            xl::Type* aa = xl::next(itr);
            xl::Type* bb = xl::next(itr);
            return xl::init_int(aa.int_value * bb.int_value);
        }) },
    );
    defer xl::free_memory(xl_dict);
    xl::printn("xl_dict: ", xl::json_stringify(xl_dict));
    xl::printn("xl_dict: ", xl::json_stringify(xl_dict, pretty: true));
}
