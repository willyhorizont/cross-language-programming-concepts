const std = @import("std");

// 1. Definisikan Tagged Union untuk mengakomodasi berbagai tipe data
pub const AnyType = enum {
    PyNone,
    PyBool,
    JsString,
    JsInt,
    JsFloat,
    PyList,
    PyDict,
    JsFunction,
};

pub const Any = union(AnyType) {
    PyNone: void,
    PyBool: bool,
    JsString: []const u8,
    JsInt: i32,
    JsFloat: f64,
    PyList: []const Any,
    PyDict: []const DictEntry,
    // Di Zig, fungsi anonim murni harus berupa fungsi statis biasa tanpa konteks luar (no closure)
    JsFunction: *const fn (args: []const Any) Any,
};

pub const DictEntry = struct {
    key: []const u8,
    value: Any,
};

// ---- Fungsi Pembantu untuk Cetak Struktur Data (karena Zig tidak punya printf otomatis untuk Union) ----
fn printAny(any: Any) void {
    switch (any) {
        .PyNone => std.debug.print("PyNone", .{}),
        .PyBool => |b| std.debug.print("PyBool({})", .{b}),
        .JsString => |s| std.debug.print("JsString(\"{s}\")", .{s}),
        .JsInt => |i| std.debug.print("JsInt({})", .{i}),
        .JsFloat => |f| std.debug.print("JsFloat({d:.3})", .{f}),
        .PyList => |l| {
            std.debug.print("PyList([", .{});
            for (l, 0..) |item, i| {
                printAny(item);
                if (i < l.len - 1) std.debug.print(", ", .{});
            }
            std.debug.print("])", .{});
        },
        .PyDict => |d| {
            std.debug.print("PyDict([", .{});
            for (d, 0..) |entry, i| {
                std.debug.print("[\"{s}\", ", .{entry.key});
                printAny(entry.value);
                std.debug.print("]", .{});
                if (i < d.len - 1) std.debug.print(", ", .{});
            }
            std.debug.print("])", .{});
        },
        .JsFunction => std.debug.print("JsFunction(<fn>)", .{}),
    }
}

// Fungsi perkalian statis untuk dimasukkan ke dalam union Any
fn multiplyFunc(args: []const Any) Any {
    if (args.len >= 2 and std.meta.activeTag(args[0]) == .JsInt and std.meta.activeTag(args[1]) == .JsInt) {
        return Any{ .JsInt = args[0].JsInt * args[1].JsInt };
    }
    return Any{ .PyNone = {} };
}

pub fn main() !void {
    // ---- Bagian 1: Support function as value (Mekanisme simulasi di Zig) ----
    // Zig tidak mendukung fungsional closure (membuat fungsi di dalam fungsi yang menangkap variabel luar).
    // Sebagai gantinya, create_multiplier digantikan dengan fungsi perkalian langsung.
    const multiply_by_two_res = multiplyFunc(&[_]Any{ Any{ .JsInt = 2 }, Any{ .JsInt = 10 } });
    std.debug.print("multiply_by_two(10): ", .{});
    printAny(multiply_by_two_res);
    std.debug.print("\n\n", .{});

    // ---- Bagian 2: Support dynamic-typed value ----

    // List campuran (menggunakan Array Literal dengan tipe Any)
    const some_python_like_list = Any{ .PyList = &[_]Any{
        Any{ .PyNone = {} },
        Any{ .PyBool = true },
        Any{ .PyBool = false },
        Any{ .JsString = "foo" },
        Any{ .JsInt = 0 },
        Any{ .JsInt = -123 },
        Any{ .JsFloat = 123.789 },
        Any{ .JsFloat = -123.789 },
        Any{ .PyList = &[_]Any{ Any{ .JsInt = 1 }, Any{ .JsInt = 2 }, Any{ .JsInt = 3 } } },
        Any{ .JsFunction = multiplyFunc },
    } };

    std.debug.print("some_python_like_list: ", .{});
    printAny(some_python_like_list);
    std.debug.print("\n\n", .{});

    // Dictionary campuran (menggunakan Array Literal dari Struct untuk preserve order)
    const some_python_like_dict = Any{ .PyDict = &[_]DictEntry{
        .{ .key = "some_null", .value = Any{ .PyNone = {} } },
        .{ .key = "some_boolean_true", .value = Any{ .PyBool = true } },
        .{ .key = "some_boolean_false", .value = Any{ .PyBool = false } },
        .{ .key = "some_string", .value = Any{ .JsString = "foo" } },
        .{ .key = "some_int_positive", .value = Any{ .JsInt = 0 } },
        .{ .key = "some_int_negative", .value = Any{ .JsInt = -123 } },
        .{ .key = "some_float_positive", .value = Any{ .JsFloat = 123.789 } },
        .{ .key = "some_float_negative", .value = Any{ .JsFloat = -123.789 } },
        .{ .key = "some_function", .value = Any{ .JsFunction = multiplyFunc } },
    } };

    std.debug.print("some_python_like_dict: ", .{});
    printAny(some_python_like_dict);
    std.debug.print("\n", .{});
}
