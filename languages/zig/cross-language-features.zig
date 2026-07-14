const std = @import("std");
const xl = @import("willyhorizont/runtime/xl.zig");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    // 1. support closure as value, or has workaround
    const say_hello = try xl.make_closure(gpa, .{}, struct {
        fn body(ctx: anytype, args: []const xl.Type) xl.Type {
            _ = ctx;
            var itr = xl.Iterator.init(args);
            const callback_function = itr.next();
            xl.print(std.heap.page_allocator, .{}, .{xl.Type{ .String = "hello" }});
            _ = callback_function.call(std.heap.page_allocator, .{});
            return xl.Type{ .None = {} };
        }
    }.body);
    defer say_hello.deinit(gpa);
    _ = say_hello.call(gpa, .{xl.make_closure(std.heap.page_allocator, .{}, struct {
        fn body(ctx: anytype, args: []const xl.Type) xl.Type {
            _ = ctx;
            _ = args;
            xl.print(std.heap.page_allocator, .{}, .{xl.Type{ .String = "world" }});
            return xl.Type{ .None = {} };
        }
    }.body) catch xl.Type{ .None = {} }});
    const create_multiplier = try xl.make_closure(gpa, .{}, struct {
        fn body(ctx_aa: anytype, args_aa: []const xl.Type) xl.Type {
            _ = ctx_aa;
            var itr_aa = xl.Iterator.init(args_aa);
            const aa = itr_aa.next();
            return xl.make_closure(std.heap.page_allocator, .{ .aa = aa }, struct {
                fn body(ctx_bb: anytype, args_bb: []const xl.Type) xl.Type {
                    var itr_bb = xl.Iterator.init(args_bb);
                    const bb = itr_bb.next();
                    return xl.Type{ .Int = ctx_bb.aa.Int * bb.Int };
                }
            }.body) catch xl.Type{ .None = {} };
        }
    }.body);
    defer create_multiplier.deinit(gpa);
    const multiply_by_two = create_multiplier.call(gpa, .{xl.Type{ .Int = 2 }});
    defer multiply_by_two.deinit(std.heap.page_allocator);
    xl.print(gpa, .{}, .{ xl.Type{ .String = "multiply_by_two(10): " }, multiply_by_two.call(gpa, .{xl.Type{ .Int = 10 }}) });
    const multiply_by_eight = create_multiplier.call(gpa, .{xl.Type{ .Int = 8 }});
    defer multiply_by_eight.deinit(std.heap.page_allocator);
    xl.print(gpa, .{}, .{ xl.Type{ .String = "multiply_by_eight(4): " }, multiply_by_eight.call(gpa, .{xl.Type{ .Int = 4 }}) });
    xl.print(gpa, .{}, .{ xl.Type{ .String = "multiply_by_two(8): " }, multiply_by_two.call(gpa, .{xl.Type{ .Int = 8 }}) });

    // 2. support dynamic-typed value, or has workaround
    const xl_list = try xl.make_list(gpa, .{
        xl.Type{ .None = {} },
        xl.Type{ .Bool = true },
        xl.Type{ .Bool = false },
        xl.Type{ .String = "foo" },
        xl.Type{ .Int = 0 },
        xl.Type{ .Int = -123 },
        xl.Type{ .Float = 123.789 },
        xl.Type{ .Float = -123.789 },
        try xl.make_list(gpa, .{ xl.Type{ .Int = 1 }, xl.Type{ .Int = 2 }, xl.Type{ .Int = 3 } }),
        try xl.make_dict(gpa, .{.{ "foo", xl.Type{ .String = "bar" } }}),
        xl.make_closure(gpa, .{}, struct {
            fn body(ctx: anytype, args: []const xl.Type) xl.Type {
                _ = ctx;
                var itr = xl.Iterator.init(args);
                const aa = itr.next();
                const bb = itr.next();
                return xl.Type{ .Int = aa.Int * bb.Int };
            }
        }.body) catch xl.Type{ .None = {} },
    });
    xl.print(gpa, .{}, .{ xl.Type{ .String = "xl_list: " }, xl_list });
    xl.print(gpa, .{ .pretty = true }, .{ xl.Type{ .String = "xl_list: " }, xl_list });
    defer xl_list.deinit(gpa);
    const xl_dict = try xl.make_dict(gpa, .{
        .{ "xl_none", xl.Type{ .None = {} } },
        .{ "xl_bool_true", xl.Type{ .Bool = true } },
        .{ "xl_bool_false", xl.Type{ .Bool = false } },
        .{ "xl_string", xl.Type{ .String = "foo" } },
        .{ "xl_int_positive", xl.Type{ .Int = 0 } },
        .{ "xl_int_negative", xl.Type{ .Int = -123 } },
        .{ "xl_float_positive", xl.Type{ .Float = 123.789 } },
        .{ "xl_float_negative", xl.Type{ .Float = -123.789 } },
        .{ "xl_list", try xl.make_list(gpa, .{ xl.Type{ .Int = 1 }, xl.Type{ .Int = 2 }, xl.Type{ .Int = 3 } }) },
        .{ "xl_dict", try xl.make_dict(gpa, .{.{ "foo", xl.Type{ .String = "bar" } }}) },
        .{ "xl_closure", xl.make_closure(gpa, .{}, struct {
            fn body(ctx: anytype, args: []const xl.Type) xl.Type {
                _ = ctx;
                var itr = xl.Iterator.init(args);
                const aa = itr.next();
                const bb = itr.next();
                return xl.Type{ .Int = aa.Int * bb.Int };
            }
        }.body) catch xl.Type{ .None = {} } },
    });
    xl.print(gpa, .{}, .{ xl.Type{ .String = "xl_dict: " }, xl_dict });
    xl.print(gpa, .{ .pretty = true }, .{ xl.Type{ .String = "xl_dict: " }, xl_dict });
    defer xl_dict.deinit(gpa);
}
