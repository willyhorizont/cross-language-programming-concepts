const std = @import("std");

// Fungsi ini menerima angka COMPTIME, dan mengembalikan tipe data FUNGSI
fn bikinFungsiKali(comptime faktor: i32) *const fn (i32) i32 {
    // Kita bikin anonymous struct di dalam scope comptime
    return struct {
        fn fungsiInternal(x: i32) i32 {
            return x * faktor; // aman karena faktor sudah konstan pas compile-time
        }
    }.fungsiInternal; // return fungsinya langsung!
}

pub fn main() void {
    // Panggil dengan comptime keyword
    const kali_delapan = bikinFungsiKali(8);

    std.debug.print("Hasil: {}\n", .{kali_delapan(4)}); // Hasil: 32
}
