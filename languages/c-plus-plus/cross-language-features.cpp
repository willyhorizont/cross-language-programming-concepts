#include <iostream>
#include <utility>
#include "../../runtimes/c-plus-plus/runtime/willyhorizont/runtime.hpp"

int main(int argc, char* argv[]) {
    /*
    1. support closure as value, or has workaround
    */
    Xl::Type say_hello = Xl::Closure([](const Xl::Type& args) -> Xl::Type {
        Xl::Type itr = args.iter();
        Xl::Type callback_function = itr.next();
        std::cout << "hello" << std::endl;
        callback_function.call();
        return Xl::None{};
    });
    say_hello.call(Xl::Closure([](const Xl::Type& args) -> Xl::Type {
        std::cout << "world" << std::endl;
        return Xl::None{};
    }));
    Xl::Type create_multiplier = Xl::Closure([](const Xl::Type& args) -> Xl::Type {
        Xl::Type itr = args.iter();
        Xl::Type aa = itr.next();
        return Xl::Closure([aa = std::move(aa)](const Xl::Type& args) -> Xl::Type {
            Xl::Type itr = args.iter();
            Xl::Type bb = itr.next();
            return Xl::Int(Xl::to_int(aa) * Xl::to_int(bb));
        });
    });
    Xl::Type multiply_by_two = create_multiplier.call(Xl::Int(2));
    std::cout << "multiply_by_two(10): " << Xl::to_int(multiply_by_two.call(Xl::Int(10))) << std::endl;
    Xl::Type multiply_by_eight = create_multiplier.call(Xl::Int(8));
    std::cout << "multiply_by_eight(4): " << Xl::to_int(multiply_by_eight.call(Xl::Int(4))) << std::endl;
    std::cout << "multiply_by_two(8): " << Xl::to_int(multiply_by_two.call(Xl::Int(8))) << std::endl;

    /*
    2. support dynamic-typed value, or has workaround
    */
    Xl::Type xl_list = Xl::List(
        Xl::None{},
        Xl::Bool(true),
        Xl::Bool(false),
        Xl::String("foo"),
        Xl::Int(0),
        Xl::Int(-123),
        Xl::Float(123.789),
        Xl::Float(-123.789),
        Xl::List(Xl::Int(1), Xl::Int(2), Xl::Int(3)),
        Xl::Dict(Xl::Pair("foo", Xl::String("bar"))),
        Xl::Closure([](const Xl::Type& args) -> Xl::Type {
            Xl::Type itr = args.iter();
            Xl::Type aa = itr.next();
            Xl::Type bb = itr.next();
            return Xl::Int(Xl::to_int(aa) * Xl::to_int(bb));
        })
    );
    std::cout << "xl_list: " << Xl::json_stringify(xl_list) << std::endl;
    std::cout << "xl_list: " << Xl::json_stringify(xl_list, { .pretty = true }) << std::endl;
    Xl::Type xl_dict = Xl::Dict(
        Xl::Pair("xl_none", Xl::None{}),
        Xl::Pair("xl_bool_true", Xl::Bool(true)),
        Xl::Pair("xl_bool_false", Xl::Bool(false)),
        Xl::Pair("xl_string", Xl::String("foo")),
        Xl::Pair("xl_int_positive", Xl::Int(0)),
        Xl::Pair("xl_int_negative", Xl::Int(-123)),
        Xl::Pair("xl_float_positive", Xl::Float(123.789)),
        Xl::Pair("xl_float_negative", Xl::Float(-123.789)),
        Xl::Pair("xl_list", Xl::List(Xl::Int(1), Xl::Int(2), Xl::Int(3))),
        Xl::Pair("xl_dict", Xl::Dict(Xl::Pair("foo", Xl::String("bar")))),
        Xl::Pair("xl_closure", Xl::Closure([](const Xl::Type& args) -> Xl::Type {
            Xl::Type itr = args.iter();
            Xl::Type aa = itr.next();
            Xl::Type bb = itr.next();
            return Xl::Int(Xl::to_int(aa) * Xl::to_int(bb));
        }))
    );
    std::cout << "xl_dict: " << Xl::json_stringify(xl_dict) << std::endl;
    std::cout << "xl_dict: " << Xl::json_stringify(xl_dict, { .pretty = true }) << std::endl;

    return 0;
}
