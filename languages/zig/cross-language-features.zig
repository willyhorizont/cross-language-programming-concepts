const std = @import("std");
const xl = @import("willyhorizont/runtime/xl.zig");

pub fn main(init: std.process.Init) !void {
    xl.init_runtime(init.gpa, init.io);

    // # ' -- 1. support lambda as value, or has workaround
    const say_hello = xl.init_lambda(.{}, struct {
        fn call(ctx: anytype, va: []const xl.Type) xl.Type {
            _ = ctx;
            var itr = xl.iter(va);
            const callback = itr.next();
            xl.print(.{xl.init_string("hello")});
            _ = callback.call(.{});
            return xl.none;
        }
    }.call);
    defer say_hello.deinit();
    _ = say_hello.call(.{xl.init_lambda(.{}, struct {
        fn call(ctx: anytype, va: []const xl.Type) xl.Type {
            _ = ctx;
            _ = va;
            xl.print(.{xl.init_string("world")});
            return xl.none;
        }
    }.call)});
    const create_multiplier = xl.init_lambda(.{}, struct {
        fn call(ctx_aa: anytype, va_aa: []const xl.Type) xl.Type {
            _ = ctx_aa;
            var itr_aa = xl.iter(va_aa);
            const aa = itr_aa.next();
            return xl.init_lambda(.{ .aa = aa }, struct {
                fn call(ctx_bb: anytype, va_bb: []const xl.Type) xl.Type {
                    var itr_bb = xl.iter(va_bb);
                    const bb = itr_bb.next();
                    return xl.init_int(ctx_bb.aa.to_int() * bb.to_int());
                }
            }.call);
        }
    }.call);
    defer create_multiplier.deinit();
    const multiply_by_two = create_multiplier.call(.{xl.init_int(2)});
    defer multiply_by_two.deinit();
    const multiply_by_eight = create_multiplier.call(.{xl.init_int(8)});
    defer multiply_by_eight.deinit();
    xl.print(.{ "multiply_by_two(8): ", xl.json_stringify(multiply_by_two.call(.{xl.init_int(8)}), .{}) });
    xl.print(.{ "multiply_by_eight(4): ", xl.json_stringify(multiply_by_eight.call(.{xl.init_int(4)}), .{}) });
    xl.print(.{ "multiply_by_two(8): ", xl.json_stringify(multiply_by_two.call(.{xl.init_int(8)}), .{}) });

    // # ' -- 2. support dynamic-typed value, or has workaround
    const xl_list = xl.init_list(.{
        xl.none,
        xl.init_bool(true),
        xl.init_bool(false),
        xl.init_string("foo"),
        xl.init_int(0),
        xl.init_int(-123),
        xl.init_float(123.789),
        xl.init_float(-123.789),
        xl.init_list(.{ xl.init_int(1), xl.init_int(2), xl.init_int(3) }),
        xl.init_dict(.{.{ "foo", xl.init_string("bar") }}),
        xl.init_lambda(.{}, struct {
            fn call(ctx: anytype, va: []const xl.Type) xl.Type {
                _ = ctx;
                var itr = xl.iter(va);
                const aa = itr.next();
                const bb = itr.next();
                return xl.init_int(aa.to_int() * bb.to_int());
            }
        }.call),
    });
    defer xl_list.deinit();
    xl.print(.{ "xl_list: ", xl.json_stringify(xl_list, .{}) });
    xl.print(.{ "xl_list: ", xl.json_stringify(xl_list, .{ .pretty = true }) });
    const xl_dict = xl.init_dict(.{
        .{ "xl_none", xl.none },
        .{ "xl_bool_true", xl.init_bool(true) },
        .{ "xl_bool_false", xl.init_bool(false) },
        .{ "xl_string", xl.init_string("foo") },
        .{ "xl_int_positive", xl.init_int(0) },
        .{ "xl_int_negative", xl.init_int(-123) },
        .{ "xl_float_positive", xl.init_float(123.789) },
        .{ "xl_float_negative", xl.init_float(-123.789) },
        .{ "xl_list", xl.init_list(.{ xl.init_int(1), xl.init_int(2), xl.init_int(3) }) },
        .{ "xl_dict", xl.init_dict(.{.{ "foo", xl.init_string("bar") }}) },
        .{ "xl_lambda", xl.init_lambda(.{}, struct {
            fn call(ctx: anytype, va: []const xl.Type) xl.Type {
                _ = ctx;
                var itr = xl.iter(va);
                const aa = itr.next();
                const bb = itr.next();
                return xl.init_int(aa.to_int() * bb.to_int());
            }
        }.call) },
    });
    defer xl_dict.deinit();
    xl.print(.{ "xl_dict: ", xl.json_stringify(xl_dict, .{}) });
    xl.print(.{ "xl_dict: ", xl.json_stringify(xl_dict, .{ .pretty = true }) });
}
