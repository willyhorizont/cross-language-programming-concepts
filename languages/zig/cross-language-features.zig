const std = @import("std");
const xl = @import("willyhorizont/runtime/xl.zig");

pub fn main(init: std.process.Init) !void {
    xl.init_runtime(init.gpa, init.io);

    // 1. support lambda as value, or has workaround
    const say_hello = xl.lambda(.{}, struct {
        fn body(ctx: anytype, va: []const xl.Type) xl.Type {
            _ = ctx;
            var itr = xl.iter(va);
            const callback_function = itr.next();
            xl.print(.{xl.string("hello")});
            _ = callback_function.call(.{});
            return xl.none;
        }
    }.body);
    defer say_hello.deinit();
    _ = say_hello.call(.{xl.lambda(.{}, struct {
        fn body(ctx: anytype, va: []const xl.Type) xl.Type {
            _ = ctx;
            _ = va;
            xl.print(.{xl.string("world")});
            return xl.none;
        }
    }.body)});
    const create_multiplier = xl.lambda(.{}, struct {
        fn body(ctx_aa: anytype, va_aa: []const xl.Type) xl.Type {
            _ = ctx_aa;
            var itr_aa = xl.iter(va_aa);
            const aa = itr_aa.next();
            return xl.lambda(.{ .aa = aa }, struct {
                fn body(ctx_bb: anytype, va_bb: []const xl.Type) xl.Type {
                    var itr_bb = xl.iter(va_bb);
                    const bb = itr_bb.next();
                    return xl.int(ctx_bb.aa.to_int() * bb.to_int());
                }
            }.body);
        }
    }.body);
    defer create_multiplier.deinit();
    const multiply_by_two = create_multiplier.call(.{xl.int(2)});
    defer multiply_by_two.deinit();
    const multiply_by_eight = create_multiplier.call(.{xl.int(8)});
    defer multiply_by_eight.deinit();
    xl.print(.{ "multiply_by_two(8): ", xl.json_stringify(multiply_by_two.call(.{xl.int(8)}), .{}) });
    xl.print(.{ "multiply_by_eight(4): ", xl.json_stringify(multiply_by_eight.call(.{xl.int(4)}), .{}) });
    xl.print(.{ "multiply_by_two(8): ", xl.json_stringify(multiply_by_two.call(.{xl.int(8)}), .{}) });

    // 2. support dynamic-typed value, or has workaround
    const xl_list = xl.list(.{
        xl.none,
        xl.bool(true),
        xl.bool(false),
        xl.string("foo"),
        xl.int(0),
        xl.int(-123),
        xl.float(123.789),
        xl.float(-123.789),
        xl.list(.{ xl.int(1), xl.int(2), xl.int(3) }),
        xl.dict(.{.{ "foo", xl.string("bar") }}),
        xl.lambda(.{}, struct {
            fn body(ctx: anytype, va: []const xl.Type) xl.Type {
                _ = ctx;
                var itr = xl.iter(va);
                const aa = itr.next();
                const bb = itr.next();
                return xl.int(aa.to_int() * bb.to_int());
            }
        }.body),
    });
    defer xl_list.deinit();
    xl.print(.{ "xl_list: ", xl.json_stringify(xl_list, .{}) });
    xl.print(.{ "xl_list: ", xl.json_stringify(xl_list, .{ .pretty = true }) });
    const xl_dict = xl.dict(.{
        .{ "xl_none", xl.none },
        .{ "xl_bool_true", xl.bool(true) },
        .{ "xl_bool_false", xl.bool(false) },
        .{ "xl_string", xl.string("foo") },
        .{ "xl_int_positive", xl.int(0) },
        .{ "xl_int_negative", xl.int(-123) },
        .{ "xl_float_positive", xl.float(123.789) },
        .{ "xl_float_negative", xl.float(-123.789) },
        .{ "xl_list", xl.list(.{ xl.int(1), xl.int(2), xl.int(3) }) },
        .{ "xl_dict", xl.dict(.{.{ "foo", xl.string("bar") }}) },
        .{ "xl_lambda", xl.lambda(.{}, struct {
            fn body(ctx: anytype, va: []const xl.Type) xl.Type {
                _ = ctx;
                var itr = xl.iter(va);
                const aa = itr.next();
                const bb = itr.next();
                return xl.int(aa.to_int() * bb.to_int());
            }
        }.body) },
    });
    defer xl_dict.deinit();
    xl.print(.{ "xl_dict: ", xl.json_stringify(xl_dict, .{}) });
    xl.print(.{ "xl_dict: ", xl.json_stringify(xl_dict, .{ .pretty = true }) });
}
