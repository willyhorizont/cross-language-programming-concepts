const std = @import("std");

// 1. Definisikan Struct yang bertindak sebagai Object/Closure
pub const Multiplier = struct {
    a: i32, // Tempat menyimpan variabel luar ("closure state")

    // Method ini bertindak sebagai fungsi anonim yang dipanggil
    pub fn call(self: Multiplier, b: i32) i32 {
        return self.a * b;
    }
};

// 2. Fungsi pembuat objek (Simulator dari create_multiplier)
pub fn createMultiplier(factor: i32) Multiplier {
    return Multiplier{ .a = factor };
}

pub fn main() !void {
    // multiply_by_two = create_multiplier(2)
    const multiply_by_two = createMultiplier(2);

    // multiply_by_eight = create_multiplier(8)
    const multiply_by_eight = createMultiplier(8);

    // Eksekusi pemanggilan fungsi via method objek
    const res1 = multiply_by_two.call(10);
    const res2 = multiply_by_eight.call(4);
    const res3 = multiply_by_two.call(8);

    // Cetak Hasil
    std.debug.print("multiply_by_two.call(10): {}\n", .{res1}); // Hasil: 20
    std.debug.print("multiply_by_eight.call(4): {}\n", .{res2}); // Hasil: 32
    std.debug.print("multiply_by_two.call(8): {}\n", .{res3}); // Hasil: 16
}
