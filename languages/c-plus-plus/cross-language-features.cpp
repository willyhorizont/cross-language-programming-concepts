#include <iostream>
#include <utility>
#include "../../runtimes/c-plus-plus/willyhorizont/runtime/xl.hpp"

int main(int argc, char* argv[]) {
    /*
    1. support lambda as value, or has workaround
    */
    XL::Type say_hello = XL::init_lambda([](const XL::Type& va) -> XL::Type {
        XL::Type itr = va.iter();
        XL::Type callback = itr.next();
        std::cout << "hello" << '\n';
        callback.call();
        return XL::NONE;
    });
    say_hello.call(XL::init_lambda([](const XL::Type& va) -> XL::Type {
        std::cout << "world" << '\n';
        return XL::NONE;
    }));
    XL::Type create_multiplier = XL::init_lambda([](const XL::Type& va) -> XL::Type {
        XL::Type itr = va.iter();
        XL::Type aa = itr.next();
        return XL::init_lambda([aa = std::move(aa)](const XL::Type& va) -> XL::Type {
            XL::Type itr = va.iter();
            XL::Type bb = itr.next();
            return XL::init_int(XL::to_int(aa) * XL::to_int(bb));
        });
    });
    XL::Type multiply_by_two = create_multiplier.call(XL::init_int(2));
    std::cout << "multiply_by_two(10): " << XL::to_int(multiply_by_two.call(XL::init_int(10))) << '\n';
    XL::Type multiply_by_eight = create_multiplier.call(XL::init_int(8));
    std::cout << "multiply_by_eight(4): " << XL::to_int(multiply_by_eight.call(XL::init_int(4))) << '\n';
    std::cout << "multiply_by_two(8): " << XL::to_int(multiply_by_two.call(XL::init_int(8))) << '\n';

    /*
    2. support dynamic-typed value, or has workaround
    */
    XL::Type xl_list = XL::init_list(
        XL::NONE,
        XL::TRUE,
        XL::FALSE,
        XL::init_string("foo"),
        XL::init_int(0),
        XL::init_int(-123),
        XL::init_float(123.789),
        XL::init_float(-123.789),
        XL::init_list(XL::init_int(1), XL::init_int(2), XL::init_int(3)),
        XL::init_dict(XL::Pair("foo", XL::init_string("bar"))),
        XL::init_lambda([](const XL::Type& va) -> XL::Type {
            XL::Type itr = va.iter();
            XL::Type aa = itr.next();
            XL::Type bb = itr.next();
            return XL::init_int(XL::to_int(aa) * XL::to_int(bb));
        })
    );
    std::cout << "xl_list: " << XL::json_stringify(xl_list) << '\n';
    std::cout << "xl_list: " << XL::json_stringify(xl_list, { .pretty = true }) << '\n';
    XL::Type xl_dict = XL::init_dict(
        XL::Pair("xl_none", XL::NONE),
        XL::Pair("xl_bool_true", XL::TRUE),
        XL::Pair("xl_bool_false", XL::FALSE),
        XL::Pair("xl_string", XL::init_string("foo")),
        XL::Pair("xl_int_positive", XL::init_int(0)),
        XL::Pair("xl_int_negative", XL::init_int(-123)),
        XL::Pair("xl_float_positive", XL::init_float(123.789)),
        XL::Pair("xl_float_negative", XL::init_float(-123.789)),
        XL::Pair("xl_list", XL::init_list(XL::init_int(1), XL::init_int(2), XL::init_int(3))),
        XL::Pair("xl_dict", XL::init_dict(XL::Pair("foo", XL::init_string("bar")))),
        XL::Pair("xl_lambda", XL::init_lambda([](const XL::Type& va) -> XL::Type {
            XL::Type itr = va.iter();
            XL::Type aa = itr.next();
            XL::Type bb = itr.next();
            return XL::init_int(XL::to_int(aa) * XL::to_int(bb));
        }))
    );
    std::cout << "xl_dict: " << XL::json_stringify(xl_dict) << '\n';
    std::cout << "xl_dict: " << XL::json_stringify(xl_dict, { .pretty = true }) << '\n';

    return 0;
}
