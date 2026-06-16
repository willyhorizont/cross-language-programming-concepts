const std = @import("std");

// Tipe data dinamis untuk menampung argumen variadik (seperti Tcl List)
pub const AnyType = enum {
    PyNone,
    JsInt,
    JsFloat,
};

pub const Any = union(AnyType) {
    PyNone: void,
    JsInt: i32,
    JsFloat: f64,
};

// =========================================================================
// REKONSTRUKSI oo::class create Function (MENGGUNAKAN STRUCT / CARA 1)
// =========================================================================
pub const Function = struct {
    factor: []const Any, // Tempat menyimpan $variadic_arguments (State dari constructor)

    // Method assign {callback_function}
    pub fn assign(self: Function, callback_function: *const fn (args: []const Any) Any) Any {
        // Mengeksekusi callback dengan melempar data state internalnya
        return callback_function(self.factor);
    }
};

// Fungsi global biasa untuk bagian Support function as value
fn say_hello(callback_function: *const fn () void) void {
    std.debug.print("hello\n", .{});
    callback_function();
}

pub fn main() !void {
    // ---- 1. Support function as value ----
    say_hello(struct {
        fn cb() void {
            std.debug.print("world\n", .{});
        }
    }.cb);

    // ---- 2. Implementasi Kasus Matematika Tcl Menggunakan Cara 1 ----

    // Function create multiplyByTwo {2}
    const multiplyByTwo = Function{ .factor = &[_]Any{Any{ .JsInt = 2 }} };

    // multiplyByTwo assign {{variadic_arguments} { ... }}
    // Kita gunakan trik inline anonymous struct untuk menyimulasikan lambda Tcl
    const res1 = multiplyByTwo.assign(struct {
        fn cb(args: []const Any) Any {
            const a = args[0].JsInt; // lassign $variadic_arguments a
            return Any{ .JsInt = a * 10 }; // expr {$a * 10}
        }
    }.cb);
    std.debug.print("multiplyByTwo(10): {}\n", .{res1.JsInt});

    // Function create multiplyByEight {8}
    const multiplyByEight = Function{ .factor = &[_]Any{Any{ .JsInt = 8 }} };

    const res2 = multiplyByEight.assign(struct {
        fn cb(args: []const Any) Any {
            const a = args[0].JsInt;
            return Any{ .JsInt = a * 4 };
        }
    }.cb);
    std.debug.print("multiplyByEight(4): {}\n", .{res2.JsInt});

    const res3 = multiplyByTwo.assign(struct {
        fn cb(args: []const Any) Any {
            const a = args[0].JsInt;
            return Any{ .JsInt = a * 8 };
        }
    }.cb);
    std.debug.print("multiplyByTwo(8): {}\n", .{res3.JsInt});

    // Function create get_rectangle_area {7 5}
    const get_rectangle_area = Function{ .factor = &[_]Any{ Any{ .JsInt = 7 }, Any{ .JsInt = 5 } } };

    const res4 = get_rectangle_area.assign(struct {
        fn cb(args: []const Any) Any {
            const a = args[0].JsInt; // lassign $variadic_arguments a b
            const b = args[1].JsInt;
            return Any{ .JsInt = a * b };
        }
    }.cb);
    std.debug.print("get_rectangle_area(7, 5): {}\n", .{res4.JsInt});

    // Function create get_triangle_area {5 12}
    const get_triangle_area = Function{ .factor = &[_]Any{ Any{ .JsInt = 5 }, Any{ .JsInt = 12 } } };

    const res5 = get_triangle_area.assign(struct {
        fn cb(args: []const Any) Any {
            const a = @as(f64, @floatFromInt(args[0].JsInt));
            const b = @as(f64, @floatFromInt(args[1].JsInt));
            return Any{ .JsFloat = 0.5 * (a * b) }; // expr {0.5 * ($a * $b)}
        }
    }.cb);
    std.debug.print("get_triangle_area(5, 12): {d:.1}\n", .{res5.JsFloat});
}
