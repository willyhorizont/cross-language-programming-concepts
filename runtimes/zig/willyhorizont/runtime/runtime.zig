const std = @import("std");

pub fn escapeString(gpa: std.mem.Allocator, s: ?[]const u8) ![]const u8 {
    const inp = s orelse return try gpa.dupe(u8, "");
    if (inp.len == 0) return try gpa.dupe(u8, "");
    var r: std.ArrayList(u8) = .empty;
    errdefer r.deinit(gpa);
    for (inp) |c| {
        switch (c) {
            '\\' => try r.appendSlice(gpa, "\\\\"),
            '"' => try r.appendSlice(gpa, "\\\""),
            '\n' => try r.appendSlice(gpa, "\\n"),
            '\r' => try r.appendSlice(gpa, "\\r"),
            '\t' => try r.appendSlice(gpa, "\\t"),
            else => try r.append(gpa, c),
        }
    }
    return r.toOwnedSlice(gpa);
}

pub const Types = enum {
    None,
    Bool,
    Int,
    Float,
    String,
    List,
    Dict,
    Closure,
};

pub const ClosureDecorator = struct {
    context: ?*anyopaque = null,
    func: *const fn (ctx: ?*anyopaque, args: []const Type) Type,
    deinit: ?*const fn (ctx: ?*anyopaque, gpa: std.mem.Allocator) void = null,
};

pub const Pair = struct { key: []const u8, val: Type };

pub const Type = union(Types) {
    None: void,
    Bool: bool,
    Int: i128,
    Float: f128,
    String: []const u8,
    List: []const Type,
    Dict: []const Pair,
    Closure: ClosureDecorator,

    pub fn call(self: Type, gpa: std.mem.Allocator, va: anytype) Type {
        switch (self) {
            .Closure => |c| {
                var args_buff: [va.len]Type = undefined;
                inline for (va, 0..) |arg, i| {
                    args_buff[i] = arg;
                }
                defer {
                    for (&args_buff) |arg| {
                        arg.deinit(gpa);
                    }
                }
                return c.func(c.context, &args_buff);
            },
            else => return Type{ .None = {} },
        }
    }

    pub fn deinit(self: Type, gpa: std.mem.Allocator) void {
        var stack: std.ArrayList(Type) = .empty;
        defer stack.deinit(gpa);
        stack.append(gpa, self) catch {
            self.emergencyDeinit(gpa);
            return;
        };
        while (stack.pop()) |current| {
            switch (current) {
                .Closure => |c| {
                    if (c.deinit) |free_func| {
                        free_func(c.context, gpa);
                    }
                },
                .List => |l| {
                    for (l) |item| {
                        stack.append(gpa, item) catch {
                            item.emergencyDeinit(gpa);
                        };
                    }
                    gpa.free(l);
                },
                .Dict => |d| {
                    for (d) |item| {
                        stack.append(gpa, item.val) catch {
                            item.val.emergencyDeinit(gpa);
                        };
                    }
                    gpa.free(d);
                },
                else => {},
            }
        }
    }

    fn emergencyDeinit(self: Type, gpa: std.mem.Allocator) void {
        switch (self) {
            .Closure => |c| {
                if (c.deinit) |free_func| {
                    free_func(c.context, gpa);
                }
            },
            .List => |l| {
                for (l) |item| {
                    item.emergencyDeinit(gpa);
                }
                gpa.free(l);
            },
            .Dict => |d| {
                for (d) |item| {
                    item.val.emergencyDeinit(gpa);
                }
                gpa.free(d);
            },
            else => {},
        }
    }
};

pub const Iterator = struct {
    iterable: []const Type,
    index: usize = 0,
    pub fn init(iterable: []const Type) Iterator {
        return .{ .iterable = iterable };
    }
    pub fn next(self: *Iterator) Type {
        if (self.index >= self.iterable.len) return Type{ .None = {} };
        const el = self.iterable[self.index];
        self.index += 1;
        return el;
    }
};

pub fn makeClosure(gpa: std.mem.Allocator, ctx_value: anytype, comptime func: anytype) !Type {
    const T = @TypeOf(ctx_value);
    const heap_ctx = try gpa.create(T);
    heap_ctx.* = ctx_value;
    const Wrapper = struct {
        fn run(opaque_ctx: ?*anyopaque, args: []const Type) Type {
            const typed_ctx: *T = @ptrCast(@alignCast(opaque_ctx.?));
            return func(typed_ctx, args);
        }
        fn deinit(opaque_ctx: ?*anyopaque, alloc: std.mem.Allocator) void {
            const typed_ctx: *T = @ptrCast(@alignCast(opaque_ctx.?));
            alloc.destroy(typed_ctx);
        }
    };
    return Type{
        .Closure = ClosureDecorator{
            .context = heap_ctx,
            .func = Wrapper.run,
            .deinit = Wrapper.deinit,
        },
    };
}

pub fn makeList(gpa: std.mem.Allocator, tuple: anytype) !Type {
    const slice = try gpa.alloc(Type, tuple.len);
    inline for (tuple, 0..) |item, i| {
        slice[i] = item;
    }
    return Type{ .List = slice };
}

pub fn makeDict(gpa: std.mem.Allocator, tuple: anytype) !Type {
    const slice = try gpa.alloc(Pair, tuple.len);
    inline for (tuple, 0..) |item, i| {
        slice[i] = item;
    }
    return Type{ .Dict = slice };
}

pub fn jsonStringify(gpa: std.mem.Allocator, a: Type, o: anytype) ![]const u8 {
    const p = if (@hasField(@TypeOf(o), "pretty")) o.pretty else false;
    var maa = std.heap.ArenaAllocator.init(gpa);
    defer maa.deinit();
    const ma = maa.allocator();
    const StkEl = struct {
        t: enum { r, v },
        v: Type,
        r: []const u8,
        d: usize,
    };
    var s: std.ArrayList(StkEl) = .empty;
    try s.append(ma, .{ .t = .v, .v = a, .r = "", .d = 0 });
    var r: std.ArrayList(u8) = .empty;
    errdefer r.deinit(gpa);
    while (s.pop()) |c| {
        if (c.t == .r) {
            try r.appendSlice(gpa, c.r);
            continue;
        }
        const v = c.v;
        const curD = c.d;
        switch (v) {
            .None => {
                try r.appendSlice(gpa, "null");
                continue;
            },
            .Bool => |bv| {
                try r.appendSlice(gpa, if (bv) "true" else "false");
                continue;
            },
            .String => |sv| {
                const svEsc = try escapeString(gpa, sv);
                defer gpa.free(svEsc);
                try r.append(gpa, '"');
                try r.appendSlice(gpa, svEsc);
                try r.append(gpa, '"');
                continue;
            },
            .Int => |iv| {
                var buf: [64]u8 = undefined;
                const str = std.fmt.bufPrint(&buf, "{d}", .{iv}) catch "0";
                try r.appendSlice(gpa, str);
                continue;
            },
            .Float => |fv| {
                var buf: [64]u8 = undefined;
                const str = std.fmt.bufPrint(&buf, "{d}", .{fv}) catch "0.0";
                try r.appendSlice(gpa, str);
                continue;
            },
            .Closure => {
                try r.appendSlice(gpa, "\"[object Function]\"");
                continue;
            },
            .List => |lv| {
                if (lv.len == 0) {
                    try r.appendSlice(gpa, "[]");
                    continue;
                }
                const childDl = curD + 1;
                var slcb: []const u8 = "]";
                if (p) {
                    var st = try ma.alloc(u8, 2 + curD * 4);
                    st[0] = '\n';
                    @memset(st[1 .. st.len - 1], ' ');
                    st[st.len - 1] = ']';
                    slcb = st;
                }
                try s.append(ma, .{ .t = .r, .v = .None, .r = slcb, .d = curD });
                var i: usize = lv.len;
                while (i > 0) {
                    i -= 1;
                    try s.append(ma, .{ .t = .v, .v = lv[i], .r = "", .d = childDl });
                    if (i > 0) {
                        var slEls: []const u8 = ",";
                        if (p) {
                            var st = try ma.alloc(u8, 2 + childDl * 4);
                            st[0] = ',';
                            st[1] = '\n';
                            @memset(st[2..], ' ');
                            slEls = st;
                        }
                        try s.append(ma, .{ .t = .r, .v = .None, .r = slEls, .d = childDl });
                    }
                }
                var slob: []const u8 = "[";
                if (p) {
                    var st = try ma.alloc(u8, 2 + childDl * 4);
                    st[0] = '[';
                    st[1] = '\n';
                    @memset(st[2..], ' ');
                    slob = st;
                }
                try s.append(ma, .{ .t = .r, .v = .None, .r = slob, .d = childDl });
                continue;
            },
            .Dict => |dv| {
                if (dv.len == 0) {
                    try r.appendSlice(gpa, "{}");
                    continue;
                }
                const childDd = curD + 1;
                var sdcb: []const u8 = "}";
                if (p) {
                    var st = try ma.alloc(u8, 2 + curD * 4);
                    st[0] = '\n';
                    @memset(st[1 .. st.len - 1], ' ');
                    st[st.len - 1] = '}';
                    sdcb = st;
                }
                try s.append(ma, .{ .t = .r, .v = .None, .r = sdcb, .d = curD });
                var i: usize = dv.len;
                while (i > 0) {
                    i -= 1;
                    const dpl = dv[i];
                    try s.append(ma, .{ .t = .v, .v = dpl.val, .r = "", .d = childDd });
                    const sdk = if (p)
                        try std.fmt.allocPrint(ma, "\"{s}\": ", .{dpl.key})
                    else
                        try std.fmt.allocPrint(ma, "\"{s}\":", .{dpl.key});
                    try s.append(ma, .{ .t = .r, .v = .None, .r = sdk, .d = childDd });
                    if (i > 0) {
                        var sdEls: []const u8 = ",";
                        if (p) {
                            var st = try ma.alloc(u8, 2 + childDd * 4);
                            st[0] = ',';
                            st[1] = '\n';
                            @memset(st[2..], ' ');
                            sdEls = st;
                        }
                        try s.append(ma, .{ .t = .r, .v = .None, .r = sdEls, .d = childDd });
                    }
                }
                var sdob: []const u8 = "{";
                if (p) {
                    var st = try ma.alloc(u8, 2 + childDd * 4);
                    st[0] = '{';
                    st[1] = '\n';
                    @memset(st[2..], ' ');
                    sdob = st;
                }
                try s.append(ma, .{ .t = .r, .v = .None, .r = sdob, .d = childDd });
                continue;
            },
            // else => {
            //     try r.appendSlice(gpa, "\"[object Zig Object]\"");
            // },
        }
    }
    return r.toOwnedSlice(gpa);
}

pub fn print(gpa: std.mem.Allocator, options: anytype, varargs: anytype) void {
    const p = if (@hasField(@TypeOf(options), "pretty")) options.pretty else false;
    inline for (varargs) |arg| {
        switch (arg) {
            .String => |s| {
                std.debug.print("{s}", .{s});
            },
            else => {
                if (jsonStringify(gpa, arg, .{ .pretty = p })) |json_str| {
                    defer gpa.free(json_str);
                    std.debug.print("{s}", .{json_str});
                } else |err| {
                    std.debug.print("XlError: Failed to print, {}", .{err});
                }
            },
        }
    }
    std.debug.print("\n", .{});
}
