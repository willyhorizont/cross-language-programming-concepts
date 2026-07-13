#include <iostream>
#include <utility>
#include "../../runtimes/c-plus-plus/willyhorizont/runtime/xl.hpp"

int main(int argc, char* argv[]) {
    /*
    1. support closure as value, or has workaround
    */
    XL::Type say_hello = XL::Closure([](const XL::Type& args) -> XL::Type {
        XL::Type itr = args.iter();
        XL::Type callback_function = itr.next();
        std::cout << "hello" << std::endl;
        callback_function.call();
        return XL::None{};
    });
    say_hello.call(XL::Closure([](const XL::Type& args) -> XL::Type {
        std::cout << "world" << std::endl;
        return XL::None{};
    }));
    XL::Type create_multiplier = XL::Closure([](const XL::Type& args) -> XL::Type {
        XL::Type itr = args.iter();
        XL::Type aa = itr.next();
        return XL::Closure([aa = std::move(aa)](const XL::Type& args) -> XL::Type {
            XL::Type itr = args.iter();
            XL::Type bb = itr.next();
            return XL::Int(XL::to_int(aa) * XL::to_int(bb));
        });
    });
    XL::Type multiply_by_two = create_multiplier.call(XL::Int(2));
    std::cout << "multiply_by_two(10): " << XL::to_int(multiply_by_two.call(XL::Int(10))) << std::endl;
    XL::Type multiply_by_eight = create_multiplier.call(XL::Int(8));
    std::cout << "multiply_by_eight(4): " << XL::to_int(multiply_by_eight.call(XL::Int(4))) << std::endl;
    std::cout << "multiply_by_two(8): " << XL::to_int(multiply_by_two.call(XL::Int(8))) << std::endl;

    /*
    2. support dynamic-typed value, or has workaround
    */
    XL::Type xl_list = XL::List(
        XL::None{},
        XL::Bool(true),
        XL::Bool(false),
        XL::String("foo"),
        XL::Int(0),
        XL::Int(-123),
        XL::Float(123.789),
        XL::Float(-123.789),
        XL::List(XL::Int(1), XL::Int(2), XL::Int(3)),
        XL::Dict(XL::Pair("foo", XL::String("bar"))),
        XL::Closure([](const XL::Type& args) -> XL::Type {
            XL::Type itr = args.iter();
            XL::Type aa = itr.next();
            XL::Type bb = itr.next();
            return XL::Int(XL::to_int(aa) * XL::to_int(bb));
        })
    );
    std::cout << "xl_list: " << XL::json_stringify(xl_list) << std::endl;
    std::cout << "xl_list: " << XL::json_stringify(xl_list, { .pretty = true }) << std::endl;
    XL::Type xl_dict = XL::Dict(
        XL::Pair("xl_none", XL::None{}),
        XL::Pair("xl_bool_true", XL::Bool(true)),
        XL::Pair("xl_bool_false", XL::Bool(false)),
        XL::Pair("xl_string", XL::String("foo")),
        XL::Pair("xl_int_positive", XL::Int(0)),
        XL::Pair("xl_int_negative", XL::Int(-123)),
        XL::Pair("xl_float_positive", XL::Float(123.789)),
        XL::Pair("xl_float_negative", XL::Float(-123.789)),
        XL::Pair("xl_list", XL::List(XL::Int(1), XL::Int(2), XL::Int(3))),
        XL::Pair("xl_dict", XL::Dict(XL::Pair("foo", XL::String("bar")))),
        XL::Pair("xl_closure", XL::Closure([](const XL::Type& args) -> XL::Type {
            XL::Type itr = args.iter();
            XL::Type aa = itr.next();
            XL::Type bb = itr.next();
            return XL::Int(XL::to_int(aa) * XL::to_int(bb));
        }))
    );
    std::cout << "xl_dict: " << XL::json_stringify(xl_dict) << std::endl;
    std::cout << "xl_dict: " << XL::json_stringify(xl_dict, { .pretty = true }) << std::endl;

    return 0;
}
