const std = @import("std");

pub const AnyType = enum {
    PyNone,
    PyBool,
    JsInt,
    JsFloat,
    JsString,
    PyList,
    PyDict,
    JsFunction,
};

const PyDictItem = struct { []const u8, Any };

pub const Any = union(AnyType) {
    PyNone: void,
    PyBool: bool,
    JsInt: i128,
    JsFloat: f128,
    JsString: []const u8,
    PyList: []const Any,
    PyDict: []const PyDictItem,
    JsFunction: Function,
};

pub const Function = struct {
    runtime_callback: *const fn (args: []const Any) Any,
    factor: []const Any,
    pub fn init(callback: *const fn (args: []const Any) Any, factor: []const Any) Function {
        return Function{
            .runtime_callback = callback,
            .factor = factor,
        };
    }
    pub fn call(self: Function, new_args: []const Any) Any {
        var buffer: [256]Any = undefined;
        const total_len = new_args.len + self.factor.len;
        if (total_len > 256) @panic("Too many arguments passed to Function call!");
        @memcpy(buffer[0..new_args.len], new_args);
        @memcpy(buffer[new_args.len..total_len], self.factor);
        return self.runtime_callback(buffer[0..total_len]);
    }
};

pub fn main() !void {
    // 1. support function as value
    const greet_and_do_something = Function.init(struct {
        fn function_body(args: []const Any) Any {
            const calback_function = args[0].JsFunction;
            std.debug.print("hello\n", .{});
            _ = calback_function.call(&[_]Any{});
            return Any{ .PyNone = {} };
        }
    }.function_body, &[_]Any{});
    _ = greet_and_do_something.call(&[_]Any{Any{ .JsFunction = (Function.init(struct {
        fn function_body(args: []const Any) Any {
            _ = args;
            std.debug.print("wold\n", .{});
            return Any{ .PyNone = {} };
        }
    }.function_body, &[_]Any{})) }});
    const multiply = Function.init(struct {
        fn function_body(args: []const Any) Any {
            const a = args[0].JsInt;
            const static_holder = struct {
                var val: [1]Any = undefined;
            };
            static_holder.val[0] = Any{ .JsInt = a };
            return Any{ .JsFunction = (Function.init(struct {
                fn function_body_inner(inner_args: []const Any) Any {
                    const b = inner_args[0].JsInt;
                    const b_factor = inner_args[1].JsInt;
                    return Any{ .JsInt = b * b_factor };
                }
            }.function_body_inner, &static_holder.val)) };
        }
    }.function_body, &[_]Any{});
    const multiply_by_two = multiply.call(&[_]Any{Any{ .JsInt = 2 }}).JsFunction;
    std.debug.print("multiply_by_two(10): {}\n", .{multiply_by_two.call(&[_]Any{Any{ .JsInt = 10 }}).JsInt});
    const multiply_by_eight = multiply.call(&[_]Any{Any{ .JsInt = 8 }}).JsFunction;
    std.debug.print("multiply_by_eight(4): {}\n", .{multiply_by_eight.call(&[_]Any{Any{ .JsInt = 4 }}).JsInt});
    std.debug.print("multiply_by_two(8): {}\n", .{multiply_by_two.call(&[_]Any{Any{ .JsInt = 8 }}).JsInt});
    const get_rectangle_area = Function.init(struct {
        fn function_body(args: []const Any) Any {
            return Any{ .JsInt = args[0].JsInt * args[1].JsInt };
        }
    }.function_body, &[_]Any{});
    std.debug.print("get_rectangle_area(7, 5): {}\n", .{get_rectangle_area.call(&[_]Any{ Any{ .JsInt = 7 }, Any{ .JsInt = 5 } }).JsInt});
    const get_block_volume = Function.init(struct {
        fn function_body(args: []const Any) Any {
            return Any{ .JsInt = args[0].JsInt * args[1].JsInt * args[2].JsInt };
        }
    }.function_body, &[_]Any{});
    const out_block = get_block_volume.call(&[_]Any{ Any{ .JsInt = 7 }, Any{ .JsInt = 5 }, Any{ .JsInt = 4 } });
    std.debug.print("get_block_volume(7, 5, 4): {}\n", .{out_block.JsInt});

    // 2. support dynamic-typed value, or has workaround
    const some_python_like_list = &[_]Any{
        Any{ .JsString = "" },
        Any{ .PyBool = true },
        Any{ .PyBool = false },
        Any{ .JsString = "foo" },
        Any{ .JsInt = 0 },
        Any{ .JsInt = -123 },
        Any{ .JsFloat = 123.789 },
        Any{ .JsFloat = -123.789 },
        Any{ .PyList = &[_]Any{ Any{ .JsInt = 1 }, Any{ .JsInt = 2 }, Any{ .JsInt = 3 } } },
        Any{ .JsFunction = (Function.init(struct {
            fn function_body(args: []const Any) Any {
                return Any{ .JsInt = args[0].JsInt * args[1].JsInt };
            }
        }.function_body, &[_]Any{})) },
    };
    std.debug.print("\nsome_python_like_list loaded. Total item: {}\n", .{some_python_like_list.len});
    const some_python_like_dict = &[_]PyDictItem{
        PyDictItem{ "some_null", Any{ .JsString = "" } },
        PyDictItem{ "some_boolean_true", Any{ .PyBool = true } },
        PyDictItem{ "some_boolean_false", Any{ .PyBool = false } },
        PyDictItem{ "some_string", Any{ .JsString = "foo" } },
        PyDictItem{ "some_int_positive", Any{ .JsInt = 0 } },
        PyDictItem{ "some_int_negative", Any{ .JsInt = -123 } },
        PyDictItem{ "some_float_positive", Any{ .JsFloat = 123.789 } },
        PyDictItem{ "some_float_negative", Any{ .JsFloat = -123.789 } },
        PyDictItem{ "some_python_like_list", Any{ .PyList = &[_]Any{ Any{ .JsInt = 1 }, Any{ .JsInt = 2 }, Any{ .JsInt = 3 } } } },
        PyDictItem{ "some_python_like_function", Any{ .JsFunction = (Function.init(struct {
            fn function_body(args: []const Any) Any {
                return Any{ .JsInt = args[0].JsInt * args[1].JsInt };
            }
        }.function_body, &[_]Any{})) } },
    };
    std.debug.print("some_python_like_dict loaded. Total key: {}\n", .{some_python_like_dict.len});
}
