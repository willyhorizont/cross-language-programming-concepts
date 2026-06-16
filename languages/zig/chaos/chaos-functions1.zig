const std = @import("std");

fn jalankanCallback(func: *const fn () void) void {
    func();
}

pub fn main() !void {
    // Trik Menulis Fungsi Inline di Zig:
    jalankanCallback(struct {
        fn cb() void {
            std.debug.print("Halo dari fungsi inline struct!\n", .{});
        }
    }.cb); // ◄ Kita lempar method .cb dari struct tanpa nama tersebut
}
