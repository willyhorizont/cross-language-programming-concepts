#include "../../runtimes/c-plus-plus/runtime/willyhorizont/runtime.hpp"

int main(int argc, char* argv[]) {
    /*
    1. support closure as value, or has workaround
    */
    xl::CrossType say_hello = xl::XlClosure([](xl::XlClosureVarArgs& varargs) -> xl::CrossType {
        xl::CrossType callback_function = varargs.getNextArguments();
        std::cout << "hello" << std::endl;

        callback_function.call();

        return xl::CrossType();
    });
    say_hello.call(xl::XlClosure([](xl::XlClosureVarArgs& varargs) -> xl::CrossType {
        std::cout << "world" << std::endl;

        return xl::CrossType();
    }));
    xl::CrossType create_multiplier = xl::XlClosure([](xl::XlClosureVarArgs& varargs) -> xl::CrossType {
        xl::CrossType aa = varargs.getNextArguments();

        return xl::CrossType(xl::XlClosure([aa = std::move(aa)](xl::XlClosureVarArgs& varargs) -> xl::CrossType {
            xl::CrossType bb = varargs.getNextArguments();

            return xl::CrossType(xl::XlInt(std::get<xl::XlInt>(aa.value) * std::get<xl::XlInt>(bb.value)));
        }));
    });
    xl::CrossType multiply_by_two = create_multiplier.call(xl::XlInt(2));
    std::cout << "multiply_by_two(10): " << std::get<xl::XlInt>(multiply_by_two.call(xl::XlInt(10)).value) << std::endl;
    xl::CrossType multiply_by_eight = create_multiplier.call(xl::XlInt(8));
    std::cout << "multiply_by_eight(4): " << std::get<xl::XlInt>(multiply_by_eight.call(xl::XlInt(4)).value) << std::endl;
    std::cout << "multiply_by_two(8): " << std::get<xl::XlInt>(multiply_by_two.call(xl::XlInt(8)).value) << std::endl;

    /*
    2. support dynamic-typed value, or has workaround
    */
    xl::CrossType xl_list = xl::to_xl_list(
        xl::XlNone{},
        xl::XlBool(true),
        xl::XlBool(false),
        xl::XlString("foo"),
        xl::XlInt(0),
        xl::XlInt(-123),
        xl::XlFloat(123.789),
        xl::XlFloat(-123.789),
        xl::to_xl_list(xl::XlInt(1), xl::XlInt(2), xl::XlInt(3)),
        xl::to_xl_dict(std::make_pair("foo", xl::XlString("bar"))),
        xl::XlClosure([](xl::XlClosureVarArgs& varargs) -> xl::CrossType {
            xl::CrossType aa = varargs.getNextArguments();
            xl::CrossType bb = varargs.getNextArguments();

            return xl::CrossType(xl::XlInt(std::get<xl::XlInt>(aa.value) * std::get<xl::XlInt>(bb.value)));
        })
    );
    std::cout << "xl_list: " << xl::json_stringify(xl_list) << std::endl;
    std::cout << "xl_list: " << xl::json_stringify(xl_list, { .pretty = true }) << std::endl;
    xl::CrossType xl_dict = xl::to_xl_dict(
        std::make_pair("xl_none", xl::XlNone{}),
        std::make_pair("xl_bool_true", xl::XlBool(true)),
        std::make_pair("xl_bool_false", xl::XlBool(false)),
        std::make_pair("xl_string", xl::XlString("foo")),
        std::make_pair("xl_int_positive", xl::XlInt(0)),
        std::make_pair("xl_int_negative", xl::XlInt(-123)),
        std::make_pair("xl_float_positive", xl::XlFloat(123.789)),
        std::make_pair("xl_float_negative", xl::XlFloat(-123.789)),
        std::make_pair("xl_list", xl::to_xl_list(xl::XlInt(1), xl::XlInt(2), xl::XlInt(3))),
        std::make_pair("xl_dict", xl::to_xl_dict(std::make_pair("foo", xl::XlString("bar")))),
        std::make_pair("xl_closure", xl::XlClosure([](xl::XlClosureVarArgs& varargs) -> xl::CrossType {
            xl::CrossType aa = varargs.getNextArguments();
            xl::CrossType bb = varargs.getNextArguments();

            return xl::CrossType(xl::XlInt(std::get<xl::XlInt>(aa.value) * std::get<xl::XlInt>(bb.value)));
        }))
    );
    std::cout << "xl_dict: " << xl::json_stringify(xl_dict) << std::endl;
    std::cout << "xl_dict: " << xl::json_stringify(xl_dict, { .pretty = true }) << std::endl;
    xl::CrossType xl_dict_indexed = to_xl_dict_indexed(
        std::make_pair("xl_none", xl::XlNone{}),
        std::make_pair("xl_bool_true", xl::XlBool(true)),
        std::make_pair("xl_bool_false", xl::XlBool(false)),
        std::make_pair("xl_string", xl::XlString("foo")),
        std::make_pair("xl_int_positive", xl::XlInt(0)),
        std::make_pair("xl_int_negative", xl::XlInt(-123)),
        std::make_pair("xl_float_positive", xl::XlFloat(123.789)),
        std::make_pair("xl_float_negative", xl::XlFloat(-123.789)),
        std::make_pair("xl_list", xl::to_xl_list(xl::XlInt(1), xl::XlInt(2), xl::XlInt(3))),
        std::make_pair("xl_dict", xl::to_xl_dict(std::make_pair("foo", xl::XlString("bar")))),
        std::make_pair("xl_closure", xl::XlClosure([](xl::XlClosureVarArgs& varargs) -> xl::CrossType {
            xl::CrossType aa = varargs.getNextArguments();
            xl::CrossType bb = varargs.getNextArguments();

            return xl::CrossType(xl::XlInt(std::get<xl::XlInt>(aa.value) * std::get<xl::XlInt>(bb.value)));
        }))
    );
    std::cout << "xl_dict_indexed: " << xl::json_stringify(xl_dict_indexed) << std::endl;
    std::cout << "xl_dict_indexed: " << xl::json_stringify(xl_dict_indexed, { .pretty = true }) << std::endl;

    return 0;
}
