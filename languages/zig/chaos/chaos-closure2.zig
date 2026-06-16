const std = @import("std");

// Tipe data dinamis untuk menampung argumen variadik (seperti Tcl List)
pub const AnyType = enum {
    PyNone,
    JsInt,
    JsFloat,
    PyList,
};

pub const Any = union(AnyType) {
    PyNone: void,
    JsInt: i32,
    JsFloat: f64,
    PyList: []const Any,
};

// OO::class create Function
pub const Function = struct {
    factor: []const Any, // Menyimpan variadic_arguments inisialisasi

    // Method assign {callback_function}
    pub fn assign(self: Function, callback_function: *const fn (args: []const Any) Any) Any {
        return callback_function(self.factor);
    }
};

// Pembantu untuk mencetak tipe Any ke terminal
fn printAny(any: Any) void {
    switch (any) {
        .PyNone => std.debug.print("PyNone", .{}),
        .JsInt => |i| std.debug.print("{}", .{i}),
        .JsFloat => |f| std.debug.print("{d:.1}", .{f}),
        .PyList => |l| {
            std.debug.print("[", .{});
            for (l, 0..) |item, i| {
                printAny(item);
                if (i < l.len - 1) std.debug.print(", ", .{});
            }
            std.debug.print("]", .{});
        },
    }
}

pub fn main() !void {
    // ---- 1. Support function as value ----
    // set say_hello {{callback_function} { ... }}
    const say_hello = fn (callback_function: *const fn () void) void {
        std.debug.print("hello\n", .{});
        callback_function();
    };

    // apply $say_hello {{} { puts "world" }}
    say_hello(fn () void {
        std.debug.print("world\n", .{});
    });

    // ---- 2. Rekonstruksi Logika Kelas TclOO Anda ----

    // Function create multiplyByTwo {2}
    const multiplyByTwo = Function{ .factor = &[_]Any{Any{ .JsInt = 2 }} };

    // multiplyByTwo assign {{variadic_arguments} { ... }}
    const res1 = multiplyByTwo.assign(fn (args: []const Any) Any {
        const a = args[0].JsInt; // lassign $variadic_arguments a
        return Any{ .JsInt = a * 10 }; // expr {$a * 10}
    });
    std.debug.print("multiplyByTwo(10): ", .{});
    printAny(res1);
    std.debug.print("\n", .{});

    // Function create multiplyByEight {8}
    const multiplyByEight = Function{ .factor = &[_]Any{Any{ .JsInt = 8 }} };
    const res2 = multiplyByEight.assign(fn (args: []const Any) Any {
        const a = args[0].JsInt;
        return Any{ .JsInt = a * 4 };
    });
    std.debug.print("multiplyByEight(4): ", .{});
    printAny(res2);
    std.debug.print("\n", .{});

    const res3 = multiplyByTwo.assign(fn (args: []const Any) Any {
        const a = args[0].JsInt;
        return Any{ .JsInt = a * 8 };
    });
    std.debug.print("multiplyByTwo(8): ", .{});
    printAny(res3);
    std.debug.print("\n", .{});

    // Function create get_rectangle_area {7 5}
    const get_rectangle_area = Function{ .factor = &[_]Any{ Any{ .JsInt = 7 }, Any{ .JsInt = 5 } } };
    const res4 = get_rectangle_area.assign(fn (args: []const Any) Any {
        const a = args[0].JsInt; // lassign $variadic_arguments a b
        const b = args[1].JsInt;
        return Any{ .JsInt = a * b }; // expr {$a * $b}
    });
    std.debug.print("get_rectangle_area(7, 5): ", .{});
    printAny(res4);
    std.debug.print("\n", .{});

    // Function create get_triangle_area {5 12}
    const get_triangle_area = Function{ .factor = &[_]Any{ Any{ .JsInt = 5 }, Any{ .JsInt = 12 } } };
    const res5 = get_triangle_area.assign(fn (args: []const Any) Any {
        const a = @as(f64, @floatFromInt(args[0].JsInt));
        const b = @as(f64, @floatFromInt(args[1].JsInt));
        return Any{ .JsFloat = 0.5 * (a * b) }; // expr {0.5 * ($a * $b)}
    });
    std.debug.print("get_triangle_area(5, 12): ", .{});
    printAny(res5);
    std.debug.print("\n", .{});
}
