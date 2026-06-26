#include "../../runtimes/c-plus-plus/runtime/willyhorizont/runtime.hpp"

int main() {
    /*
    1. support closure as value
    */
    CrossType say_hello = XlClosure([](std::shared_ptr<XlClosureVarArgs> varargs) -> CrossType {
        CrossType callback_function = varargs->getNextArguments();
        std::cout << "hello" << std::endl;

        XlClosure(std::get<XlClosure>(callback_function.value))(to_xl_closure_varargs(XlNone{}));

        return CrossType(XlNone{});
    });
    XlClosure(std::get<XlClosure>(say_hello.value))(to_xl_closure_varargs(XlClosure([](std::shared_ptr<XlClosureVarArgs> varargs) -> CrossType {
        std::cout << "world" << std::endl;

        return CrossType(XlNone{});
    })));
    CrossType create_multiplier = XlClosure([](std::shared_ptr<XlClosureVarArgs> varargs) -> CrossType {
        CrossType aa = varargs->getNextArguments();

        return CrossType(XlClosure([aa = std::move(aa)](std::shared_ptr<XlClosureVarArgs> varargs) -> CrossType {
            CrossType bb = varargs->getNextArguments();

            return CrossType(XlInt(std::get<XlInt>(aa.value) * std::get<XlInt>(bb.value)));
        }));
    });
    CrossType multiply_by_two = XlClosure(std::get<XlClosure>(create_multiplier.value))(to_xl_closure_varargs(XlInt(2)));
    std::cout << "multiply_by_two(10): " << std::get<XlInt>(XlClosure(std::get<XlClosure>(multiply_by_two.value))(to_xl_closure_varargs(XlInt(10))).value) << std::endl;
    CrossType multiply_by_eight = XlClosure(std::get<XlClosure>(create_multiplier.value))(to_xl_closure_varargs(XlInt(8)));
    std::cout << "multiply_by_eight(4): " << std::get<XlInt>(XlClosure(std::get<XlClosure>(multiply_by_eight.value))(to_xl_closure_varargs(XlInt(4))).value) << std::endl;
    std::cout << "multiply_by_two(8): " << std::get<XlInt>(XlClosure(std::get<XlClosure>(multiply_by_two.value))(to_xl_closure_varargs(XlInt(8))).value) << std::endl;

    /*
    2. support dynamic-typed value, or has workaround
    */
    CrossType xl_list = to_xl_list(
        XlNone{},
        XlBool(true),
        XlBool(false),
        XlString("foo"),
        XlInt(0),
        XlInt(-123),
        XlFloat(123.789),
        XlFloat(-123.789),
        to_xl_list(XlInt(1), XlInt(2), XlInt(3)),
        to_xl_dict(std::make_pair("foo", XlString("bar"))),
        XlClosure([](std::shared_ptr<XlClosureVarArgs> varargs) -> CrossType {
            CrossType aa = varargs->getNextArguments();
            CrossType bb = varargs->getNextArguments();

            return CrossType(XlInt(std::get<XlInt>(aa.value) * std::get<XlInt>(bb.value)));
        })
    );
    std::cout << "xl_list: " << json_stringify(xl_list) << std::endl;
    std::cout << "xl_list: " << json_stringify(xl_list, { .pretty = true }) << std::endl;
    CrossType xl_dict = to_xl_dict(
        std::make_pair("xl_none", XlNone{}),
        std::make_pair("xl_bool_true", XlBool(true)),
        std::make_pair("xl_bool_false", XlBool(false)),
        std::make_pair("xl_string", XlString("foo")),
        std::make_pair("xl_int_positive", XlInt(0)),
        std::make_pair("xl_int_negative", XlInt(-123)),
        std::make_pair("xl_float_positive", XlFloat(123.789)),
        std::make_pair("xl_float_negative", XlFloat(-123.789)),
        std::make_pair("xl_list", to_xl_list(XlInt(1), XlInt(2), XlInt(3))),
        std::make_pair("xl_dict", to_xl_dict(std::make_pair("foo", XlString("bar")))),
        std::make_pair("xl_closure", XlClosure([](std::shared_ptr<XlClosureVarArgs> varargs) -> CrossType {
            CrossType aa = varargs->getNextArguments();
            CrossType bb = varargs->getNextArguments();

            return CrossType(XlInt(std::get<XlInt>(aa.value) * std::get<XlInt>(bb.value)));
        }))
    );
    std::cout << "xl_dict: " << json_stringify(xl_dict) << std::endl;
    std::cout << "xl_dict: " << json_stringify(xl_dict, { .pretty = true }) << std::endl;
    CrossType xl_dict_indexed = to_xl_dict_indexed(
        std::make_pair("xl_none", XlNone{}),
        std::make_pair("xl_bool_true", XlBool(true)),
        std::make_pair("xl_bool_false", XlBool(false)),
        std::make_pair("xl_string", XlString("foo")),
        std::make_pair("xl_int_positive", XlInt(0)),
        std::make_pair("xl_int_negative", XlInt(-123)),
        std::make_pair("xl_float_positive", XlFloat(123.789)),
        std::make_pair("xl_float_negative", XlFloat(-123.789)),
        std::make_pair("xl_list", to_xl_list(XlInt(1), XlInt(2), XlInt(3))),
        std::make_pair("xl_dict", to_xl_dict(std::make_pair("foo", XlString("bar")))),
        std::make_pair("xl_closure", XlClosure([](std::shared_ptr<XlClosureVarArgs> varargs) -> CrossType {
            CrossType aa = varargs->getNextArguments();
            CrossType bb = varargs->getNextArguments();

            return CrossType(XlInt(std::get<XlInt>(aa.value) * std::get<XlInt>(bb.value)));
        }))
    );
    std::cout << "xl_dict_indexed: " << json_stringify(xl_dict_indexed) << std::endl;
    std::cout << "xl_dict_indexed: " << json_stringify(xl_dict_indexed, { .pretty = true }) << std::endl;

    return 0;
}
