const std = @import("std");

const KapsulAngka = struct {
    faktor: i32,
    // Ini fungsi di dalam struct (method)
    pub fn kalikan(self: KapsulAngka, x: i32) i32 {
        return self.faktor * x;
    }
};

// Fungsi ini mengembalikan/return sebuah STRUCT
fn bikinPekali(angka: i32) KapsulAngka {
    return KapsulAngka{ .faktor = angka };
}

pub fn main() void {
    const kali_dua = bikinPekali(2); // return struct
    std.debug.print("Hasil: {}\n", .{kali_dua.kalikan(10)}); // Hasil: 20
}
