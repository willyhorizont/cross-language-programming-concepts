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

// ---- PERBAIKAN 1: Pindahkan Fungsi ke Global Scope ----
// Zig mewajibkan fungsi dideklarasikan di level struktur/modul luar, bukan di dalam main()
fn say_hello(callback_function: *const fn () void) void {
    std.debug.print("hello\n", .{});
    callback_function();
}

fn print_world() void {
    std.debug.print("world\n", .{});
}

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
            std.debug.print("])", .{});
        },
    }
}

// ---- PERBAIKAN 2: Callback functions dipisah agar sintaksis kompilasi bersih ----
fn cb_mult_two_10(args: []const Any) Any {
    const a = args[0].JsInt;
    return Any{ .JsInt = a * 10 };
}

fn cb_mult_eight_4(args: []const Any) Any {
    const a = args[0].JsInt;
    return Any{ .JsInt = a * 4 };
}

fn cb_mult_two_8(args: []const Any) Any {
    const a = args[0].JsInt;
    return Any{ .JsInt = a * 8 };
}

fn cb_rect_area(args: []const Any) Any {
    const a = args[0].JsInt;
    const b = args[1].JsInt;
    return Any{ .JsInt = a * b };
}

fn cb_tri_area(args: []const Any) Any {
    const a = @as(f64, @floatFromInt(args[0].JsInt));
    const b = @as(f64, @floatFromInt(args[1].JsInt));
    return Any{ .JsFloat = 0.5 * (a * b) };
}

pub fn main() !void {
    // ---- 1. Support function as value ----
    say_hello(print_world);

    // ---- 2. Rekonstruksi Logika Kelas TclOO Anda ----

    // Function create multiplyByTwo {2}
    const multiplyByTwo = Function{ .factor = &[_]Any{Any{ .JsInt = 2 }} };

    const res1 = multiplyByTwo.assign(cb_mult_two_10);
    std.debug.print("multiplyByTwo(10): ", .{});
    printAny(res1);
    std.debug.print("\n", .{});

    // Function create multiplyByEight {8}
    const multiplyByEight = Function{ .factor = &[_]Any{Any{ .JsInt = 8 }} };
    const res2 = multiplyByEight.assign(cb_mult_eight_4);
    std.debug.print("multiplyByEight(4): ", .{});
    printAny(res2);
    std.debug.print("\n", .{});

    const res3 = multiplyByTwo.assign(cb_mult_two_8);
    std.debug.print("multiplyByTwo(8): ", .{});
    printAny(res3);
    std.debug.print("\n", .{});

    // Function create get_rectangle_area {7 5}
    const get_rectangle_area = Function{ .factor = &[_]Any{ Any{ .JsInt = 7 }, Any{ .JsInt = 5 } } };
    const res4 = get_rectangle_area.assign(cb_rect_area);
    std.debug.print("get_rectangle_area(7, 5): ", .{});
    printAny(res4);
    std.debug.print("\n", .{});

    // Function create get_triangle_area {5 12}
    const get_triangle_area = Function{ .factor = &[_]Any{ Any{ .JsInt = 5 }, Any{ .JsInt = 12 } } };
    const res5 = get_triangle_area.assign(cb_tri_area);
    std.debug.print("get_triangle_area(5, 12): ", .{});
    printAny(res5);
    std.debug.print("\n", .{});
}
