const std = @import("std");
const xl = @import("willyhorizont/runtime/xl.zig");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    // 1. support closure as value, or has workaround
    const say_hello = try xl.makeClosure(gpa, .{}, struct {
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
    _ = say_hello.call(gpa, .{xl.makeClosure(std.heap.page_allocator, .{}, struct {
        fn body(ctx: anytype, args: []const xl.Type) xl.Type {
            _ = ctx;
            _ = args;
            xl.print(std.heap.page_allocator, .{}, .{xl.Type{ .String = "world" }});
            return xl.Type{ .None = {} };
        }
    }.body) catch xl.Type{ .None = {} }});
    const createMultiplier = try xl.makeClosure(gpa, .{}, struct {
        fn body(ctx_aa: anytype, args_aa: []const xl.Type) xl.Type {
            _ = ctx_aa;
            var itr_aa = xl.Iterator.init(args_aa);
            const aa = itr_aa.next();
            return xl.makeClosure(std.heap.page_allocator, .{ .aa = aa }, struct {
                fn body(ctx_bb: anytype, args_bb: []const xl.Type) xl.Type {
                    var itr_bb = xl.Iterator.init(args_bb);
                    const bb = itr_bb.next();
                    return xl.Type{ .Int = ctx_bb.aa.Int * bb.Int };
                }
            }.body) catch xl.Type{ .None = {} };
        }
    }.body);
    defer createMultiplier.deinit(gpa);
    const multiplyByTwo = createMultiplier.call(gpa, .{xl.Type{ .Int = 2 }});
    defer multiplyByTwo.deinit(std.heap.page_allocator);
    xl.print(gpa, .{}, .{ xl.Type{ .String = "multiply_by_two(10): " }, multiplyByTwo.call(gpa, .{xl.Type{ .Int = 10 }}) });
    const multiplyByEight = createMultiplier.call(gpa, .{xl.Type{ .Int = 8 }});
    defer multiplyByEight.deinit(std.heap.page_allocator);
    xl.print(gpa, .{}, .{ xl.Type{ .String = "multiply_by_eight(4): " }, multiplyByEight.call(gpa, .{xl.Type{ .Int = 4 }}) });
    xl.print(gpa, .{}, .{ xl.Type{ .String = "multiply_by_two(8): " }, multiplyByTwo.call(gpa, .{xl.Type{ .Int = 8 }}) });

    // 2. support dynamic-typed value, or has workaround
    const xl_list = try xl.makeList(gpa, .{
        xl.Type{ .None = {} },
        xl.Type{ .Bool = true },
        xl.Type{ .Bool = false },
        xl.Type{ .String = "foo" },
        xl.Type{ .Int = 0 },
        xl.Type{ .Int = -123 },
        xl.Type{ .Float = 123.789 },
        xl.Type{ .Float = -123.789 },
        try xl.makeList(gpa, .{ xl.Type{ .Int = 1 }, xl.Type{ .Int = 2 }, xl.Type{ .Int = 3 } }),
        try xl.makeDict(gpa, .{xl.Pair{ .key = "foo", .val = xl.Type{ .String = "bar" } }}),
        xl.makeClosure(gpa, .{}, struct {
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
    const xl_dict = try xl.makeDict(gpa, .{
        xl.Pair{ .key = "xl_none", .val = xl.Type{ .None = {} } },
        xl.Pair{ .key = "xl_bool_true", .val = xl.Type{ .Bool = true } },
        xl.Pair{ .key = "xl_bool_false", .val = xl.Type{ .Bool = false } },
        xl.Pair{ .key = "xl_string", .val = xl.Type{ .String = "foo" } },
        xl.Pair{ .key = "xl_int_positive", .val = xl.Type{ .Int = 0 } },
        xl.Pair{ .key = "xl_int_negative", .val = xl.Type{ .Int = -123 } },
        xl.Pair{ .key = "xl_float_positive", .val = xl.Type{ .Float = 123.789 } },
        xl.Pair{ .key = "xl_float_negative", .val = xl.Type{ .Float = -123.789 } },
        xl.Pair{ .key = "xl_list", .val = try xl.makeList(gpa, .{ xl.Type{ .Int = 1 }, xl.Type{ .Int = 2 }, xl.Type{ .Int = 3 } }) },
        xl.Pair{ .key = "xl_dict", .val = try xl.makeDict(gpa, .{xl.Pair{ .key = "foo", .val = xl.Type{ .String = "bar" } }}) },
        xl.Pair{ .key = "xl_closure", .val = xl.makeClosure(gpa, .{}, struct {
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
