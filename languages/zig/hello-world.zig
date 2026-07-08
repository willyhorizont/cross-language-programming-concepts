const std = @import("std");
const xl = @import("willyhorizont/runtime/runtime.zig");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    std.debug.print("hello, world\n", .{});
    xl.print(gpa, .{}, .{ xl.Type{ .String = "hello, world" } });
}
