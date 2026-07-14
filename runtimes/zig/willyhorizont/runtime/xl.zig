const std = @import("std");

pub fn escape_string(gpa: std.mem.Allocator, s: ?[]const u8) ![]const u8 {
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

pub const XlClosure = struct {
    context: ?*anyopaque = null,
    func: *const fn (ctx: ?*anyopaque, args: []const Type) Type,
    deinit: ?*const fn (ctx: ?*anyopaque, gpa: std.mem.Allocator) void = null,
};

pub const XlDict = std.hash_map.StringHashMap(Type);

pub const Type = union(Types) {
    None: void,
    Bool: bool,
    Int: i128,
    Float: f128,
    String: []const u8,
    List: []const Type,
    Dict: XlDict,
    Closure: XlClosure,

    pub fn call(self: Type, gpa: std.mem.Allocator, va: anytype) Type {
        switch (self) {
            .Closure => |c| {
                var args_buff: [va.len]Type = undefined;
                inline for (va, 0..) |a, i| {
                    args_buff[i] = a;
                }
                defer {
                    for (&args_buff) |a| {
                        a.deinit(gpa);
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
            self.emergency_deinit(gpa);
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
                    for (l) |el| {
                        stack.append(gpa, el) catch {
                            el.emergency_deinit(gpa);
                        };
                    }
                    gpa.free(l);
                },
                .Dict => |d| {
                    var d_mut = d;
                    var itr = d_mut.iterator();
                    while (itr.next()) |dp| {
                        stack.append(gpa, dp.value_ptr.*) catch {
                            dp.value_ptr.*.emergency_deinit(gpa);
                        };
                        gpa.free(dp.key_ptr.*);
                    }
                    d_mut.deinit();
                },
                else => {},
            }
        }
    }

    fn emergency_deinit(self: Type, gpa: std.mem.Allocator) void {
        switch (self) {
            .Closure => |c| {
                if (c.deinit) |free_func| {
                    free_func(c.context, gpa);
                }
            },
            .List => |l| {
                for (l) |el| {
                    el.emergency_deinit(gpa);
                }
                gpa.free(l);
            },
            .Dict => |d| {
                var d_mut = d;
                var itr = d_mut.iterator();
                while (itr.next()) |dp| {
                    dp.value_ptr.*.emergency_deinit(gpa);
                    gpa.free(dp.key_ptr.*);
                }
                d_mut.deinit();
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

pub fn make_closure(gpa: std.mem.Allocator, ctx_value: anytype, comptime func: anytype) !Type {
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
        .Closure = XlClosure{
            .context = heap_ctx,
            .func = Wrapper.run,
            .deinit = Wrapper.deinit,
        },
    };
}

pub fn make_list(gpa: std.mem.Allocator, dp: anytype) !Type {
    const slice = try gpa.alloc(Type, dp.len);
    inline for (dp, 0..) |el, i| {
        slice[i] = el;
    }
    return Type{ .List = slice };
}

pub fn make_dict(gpa: std.mem.Allocator, p: anytype) !Type {
    var d = XlDict.init(gpa);
    errdefer {
        var itr = d.iterator();
        while (itr.next()) |dp| gpa.free(dp.key_ptr.*);
        d.deinit();
    }
    inline for (p) |el| {
        const k_cpy = try gpa.dupe(u8, el[0]);
        errdefer gpa.free(k_cpy);
        try d.put(k_cpy, el[1]);
    }
    return Type{ .Dict = d };
}

pub fn json_stringify(gpa: std.mem.Allocator, a: Type, o: anytype) ![]const u8 {
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
        const cur_d = c.d;
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
                const sv_esc = try escape_string(gpa, sv);
                defer gpa.free(sv_esc);
                try r.append(gpa, '"');
                try r.appendSlice(gpa, sv_esc);
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
                const child_dl = cur_d + 1;
                var slcb: []const u8 = "]";
                if (p) {
                    var st = try ma.alloc(u8, 2 + cur_d * 4);
                    st[0] = '\n';
                    @memset(st[1 .. st.len - 1], ' ');
                    st[st.len - 1] = ']';
                    slcb = st;
                }
                try s.append(ma, .{ .t = .r, .v = .None, .r = slcb, .d = cur_d });
                var i: usize = lv.len;
                while (i > 0) {
                    i -= 1;
                    try s.append(ma, .{ .t = .v, .v = lv[i], .r = "", .d = child_dl });
                    if (i > 0) {
                        var sl_el_sep: []const u8 = ",";
                        if (p) {
                            var st = try ma.alloc(u8, 2 + child_dl * 4);
                            st[0] = ',';
                            st[1] = '\n';
                            @memset(st[2..], ' ');
                            sl_el_sep = st;
                        }
                        try s.append(ma, .{ .t = .r, .v = .None, .r = sl_el_sep, .d = child_dl });
                    }
                }
                var slob: []const u8 = "[";
                if (p) {
                    var st = try ma.alloc(u8, 2 + child_dl * 4);
                    st[0] = '[';
                    st[1] = '\n';
                    @memset(st[2..], ' ');
                    slob = st;
                }
                try s.append(ma, .{ .t = .r, .v = .None, .r = slob, .d = child_dl });
                continue;
            },
            .Dict => |dv| {
                var dv_mut = dv;
                if (dv_mut.count() == 0) {
                    try r.appendSlice(gpa, "{}");
                    continue;
                }
                const child_dd = cur_d + 1;
                var sdcb: []const u8 = "}";
                if (p) {
                    var st = try ma.alloc(u8, 2 + cur_d * 4);
                    st[0] = '\n';
                    @memset(st[1 .. st.len - 1], ' ');
                    st[st.len - 1] = '}';
                    sdcb = st;
                }
                try s.append(ma, .{ .t = .r, .v = .None, .r = sdcb, .d = cur_d });
                var itr = dv_mut.iterator();
                var is_first_prcsed = true;
                while (itr.next()) |dp| {
                    if (!is_first_prcsed) {
                        var sd_el_sep: []const u8 = ",";
                        if (p) {
                            var st = try ma.alloc(u8, 2 + child_dd * 4);
                            st[0] = ',';
                            st[1] = '\n';
                            @memset(st[2..], ' ');
                            sd_el_sep = st;
                        }
                        try s.append(ma, .{ .t = .r, .v = .None, .r = sd_el_sep, .d = child_dd });
                    }
                    try s.append(ma, .{ .t = .v, .v = dp.value_ptr.*, .r = "", .d = child_dd });
                    const sdk = if (p)
                        try std.fmt.allocPrint(ma, "\"{s}\": ", .{dp.key_ptr.*})
                    else
                        try std.fmt.allocPrint(ma, "\"{s}\":", .{dp.key_ptr.*});
                    try s.append(ma, .{ .t = .r, .v = .None, .r = sdk, .d = child_dd });
                    is_first_prcsed = false;
                }
                var sdob: []const u8 = "{";
                if (p) {
                    var st = try ma.alloc(u8, 2 + child_dd * 4);
                    st[0] = '{';
                    st[1] = '\n';
                    @memset(st[2..], ' ');
                    sdob = st;
                }
                try s.append(ma, .{ .t = .r, .v = .None, .r = sdob, .d = child_dd });
                continue;
            },
        }
    }
    return r.toOwnedSlice(gpa);
}

pub fn print(gpa: std.mem.Allocator, o: anytype, va: anytype) void {
    const p = if (@hasField(@TypeOf(o), "pretty")) o.pretty else false;
    inline for (va) |a| {
        switch (a) {
            .String => |s| {
                std.debug.print("{s}", .{s});
            },
            else => {
                if (json_stringify(gpa, a, .{ .pretty = p })) |json_str| {
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
