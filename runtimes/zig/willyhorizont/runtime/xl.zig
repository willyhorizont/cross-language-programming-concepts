const std = @import("std");

var global_io: ?std.Io = null;
var global_allocator: ?std.mem.Allocator = null;

pub fn init_runtime(gpa: std.mem.Allocator, io: std.Io) void {
    global_allocator = gpa;
    global_io = io;
}

pub fn escape_string(allocator: std.mem.Allocator, s: ?[]const u8) ![]const u8 {
    const inp = s orelse return try allocator.dupe(u8, "");
    if (inp.len == 0) return try allocator.dupe(u8, "");
    var r: std.ArrayList(u8) = .empty;
    errdefer r.deinit(allocator);
    for (inp) |c| {
        switch (c) {
            '\\' => try r.appendSlice(allocator, "\\\\"),
            '"' => try r.appendSlice(allocator, "\\\""),
            '\n' => try r.appendSlice(allocator, "\\n"),
            '\r' => try r.appendSlice(allocator, "\\r"),
            '\t' => try r.appendSlice(allocator, "\\t"),
            else => try r.append(allocator, c),
        }
    }
    return r.toOwnedSlice(allocator);
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

    pub fn call(self: Type, va: anytype) Type {
        switch (self) {
            .Closure => |c| {
                var args_buff: [va.len]Type = undefined;
                inline for (va, 0..) |a, i| {
                    args_buff[i] = a;
                }
                defer {
                    for (&args_buff) |a| {
                        a.deinit();
                    }
                }
                return c.func(c.context, &args_buff);
            },
            else => return none,
        }
    }

    pub fn deinit(self: Type) void {
        const gpa = global_allocator.?;
        var stack: std.ArrayList(Type) = .empty;
        defer stack.deinit(gpa);
        stack.append(gpa, self) catch {
            self.emergency_deinit();
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
                            el.emergency_deinit();
                        };
                    }
                    gpa.free(l);
                },
                .Dict => |d| {
                    var d_mut = d;
                    var itr = d_mut.iterator();
                    while (itr.next()) |dp| {
                        stack.append(gpa, dp.value_ptr.*) catch {
                            dp.value_ptr.*.emergency_deinit();
                        };
                        gpa.free(dp.key_ptr.*);
                    }
                    d_mut.deinit();
                },
                else => {},
            }
        }
    }

    fn emergency_deinit(self: Type) void {
        const gpa = global_allocator.?;
        switch (self) {
            .Closure => |c| {
                if (c.deinit) |free_func| free_func(c.context, gpa);
            },
            .List => |l| {
                for (l) |el| {
                    el.emergency_deinit();
                }
                gpa.free(l);
            },
            .Dict => |d| {
                var d_mut = d;
                var itr = d_mut.iterator();
                while (itr.next()) |dp| {
                    dp.value_ptr.*.emergency_deinit();
                    gpa.free(dp.key_ptr.*);
                }
                d_mut.deinit();
            },
            else => {},
        }
    }

    pub fn to_bool(self: Type) bool {
        return switch (self) {
            .Bool => |b| b,
            else => @panic("XlRuntimeError: expected Bool."),
        };
    }

    pub fn to_int(self: Type) i128 {
        return switch (self) {
            .Int => |i| i,
            else => @panic("XlRuntimeError: expected Int."),
        };
    }

    pub fn to_float(self: Type) f128 {
        return switch (self) {
            .Float => |f| f,
            else => @panic("XlRuntimeError: expected Float."),
        };
    }

    pub fn to_string(self: Type) []const u8 {
        return switch (self) {
            .String => |s| s,
            else => @panic("XlRuntimeError: expected String."),
        };
    }
};

pub const none = Type{ .None = {} };

pub const Iterator = struct {
    iterable: []const Type,
    index: usize = 0,
    pub fn init(iterable: []const Type) Iterator {
        return .{ .iterable = iterable };
    }
    pub fn next(self: *Iterator) Type {
        if (self.index >= self.iterable.len) return none;
        const el = self.iterable[self.index];
        self.index += 1;
        return el;
    }
};

pub fn iter(iterable: []const Type) Iterator {
    return Iterator.init(iterable);
}

pub fn @"bool"(v: bool) Type {
    return Type{ .Bool = v };
}

pub fn int(v: i128) Type {
    return Type{ .Int = v };
}

pub fn float(v: f128) Type {
    return Type{ .Float = v };
}

pub fn string(v: []const u8) Type {
    return Type{ .String = v };
}

pub fn list(dp: anytype) Type {
    const gpa = global_allocator.?;
    const l = gpa.alloc(Type, dp.len) catch @panic("XlRuntimeError: Out of memory while allocating list.");
    inline for (dp, 0..) |el, i| {
        l[i] = el;
    }
    return Type{ .List = l };
}

pub fn dict(p: anytype) Type {
    const gpa = global_allocator.?;
    var d = XlDict.init(gpa);
    errdefer {
        var itr = d.iterator();
        while (itr.next()) |dp| gpa.free(dp.key_ptr.*);
        d.deinit();
    }
    inline for (p) |el| {
        const k_cpy = gpa.dupe(u8, el.@"0") catch @panic("XlRuntimeError: Out of memory while copying dict key.");
        errdefer gpa.free(k_cpy);
        d.put(k_cpy, el.@"1") catch @panic("XlRuntimeError: Out of memory while inserting dict pair.");
    }
    return Type{ .Dict = d };
}

pub fn closure(ctx_value: anytype, comptime func: anytype) Type {
    const gpa = global_allocator.?;
    const T = @TypeOf(ctx_value);
    const heap_ctx = gpa.create(T) catch @panic("XlRuntimeError: Out of memory while allocating closure context.");
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
const jify_err_msg = "XlRuntimeError: Out of memory while performing json_stringify.";

pub fn json_stringify(a: Type, o: anytype) []const u8 {
    const gpa = global_allocator.?;
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
    defer s.deinit(ma);
    s.append(ma, .{ .t = .v, .v = a, .r = "", .d = 0 }) catch @panic(jify_err_msg);
    var r: std.ArrayList(u8) = .empty;
    while (s.pop()) |c| {
        if (c.t == .r) {
            r.appendSlice(gpa, c.r) catch @panic(jify_err_msg);
            continue;
        }
        const v = c.v;
        const cur_d = c.d;
        switch (v) {
            .None => {
                r.appendSlice(gpa, "null") catch @panic(jify_err_msg);
                continue;
            },
            .Bool => |bv| {
                r.appendSlice(gpa, if (bv) "true" else "false") catch @panic(jify_err_msg);
                continue;
            },
            .String => |sv| {
                r.append(gpa, '"') catch @panic(jify_err_msg);
                r.appendSlice(gpa, escape_string(ma, sv) catch @panic(jify_err_msg)) catch @panic(jify_err_msg);
                r.append(gpa, '"') catch @panic(jify_err_msg);
                continue;
            },
            .Int => |iv| {
                var buf: [64]u8 = undefined;
                const str = std.fmt.bufPrint(&buf, "{d}", .{iv}) catch "0";
                r.appendSlice(gpa, str) catch @panic(jify_err_msg);
                continue;
            },
            .Float => |fv| {
                var buf: [64]u8 = undefined;
                const str = std.fmt.bufPrint(&buf, "{d}", .{fv}) catch "0.0";
                r.appendSlice(gpa, str) catch @panic(jify_err_msg);
                continue;
            },
            .Closure => {
                r.appendSlice(gpa, "\"[object Function]\"") catch @panic(jify_err_msg);
                continue;
            },
            .List => |lv| {
                if (lv.len == 0) {
                    r.appendSlice(gpa, "[]") catch @panic(jify_err_msg);
                    continue;
                }
                const child_dl = cur_d + 1;
                var slcb: []const u8 = "]";
                if (p) {
                    var st = ma.alloc(u8, 2 + cur_d * 4) catch @panic(jify_err_msg);
                    st[0] = '\n';
                    @memset(st[1 .. st.len - 1], ' ');
                    st[st.len - 1] = ']';
                    slcb = st;
                }
                s.append(ma, .{ .t = .r, .v = .None, .r = slcb, .d = cur_d }) catch @panic(jify_err_msg);
                var i: usize = lv.len;
                while (i > 0) {
                    i -= 1;
                    s.append(ma, .{ .t = .v, .v = lv[i], .r = "", .d = child_dl }) catch @panic(jify_err_msg);
                    if (i > 0) {
                        var sl_el_sep: []const u8 = ",";
                        if (p) {
                            var st = ma.alloc(u8, 2 + child_dl * 4) catch @panic(jify_err_msg);
                            st[0] = ',';
                            st[1] = '\n';
                            @memset(st[2..], ' ');
                            sl_el_sep = st;
                        }
                        s.append(ma, .{ .t = .r, .v = .None, .r = sl_el_sep, .d = child_dl }) catch @panic(jify_err_msg);
                    }
                }
                var slob: []const u8 = "[";
                if (p) {
                    var st = ma.alloc(u8, 2 + child_dl * 4) catch @panic(jify_err_msg);
                    st[0] = '[';
                    st[1] = '\n';
                    @memset(st[2..], ' ');
                    slob = st;
                }
                s.append(ma, .{ .t = .r, .v = .None, .r = slob, .d = child_dl }) catch @panic(jify_err_msg);
                continue;
            },
            .Dict => |dv| {
                var dv_mut = dv;
                const dpl_len = dv_mut.count();
                if (dpl_len == 0) {
                    r.appendSlice(gpa, "{}") catch @panic(jify_err_msg);
                    continue;
                }
                const child_dd = cur_d + 1;
                var sdcb: []const u8 = "}";
                if (p) {
                    var st = ma.alloc(u8, 2 + cur_d * 4) catch @panic(jify_err_msg);
                    st[0] = '\n';
                    @memset(st[1 .. st.len - 1], ' ');
                    st[st.len - 1] = '}';
                    sdcb = st;
                }
                s.append(ma, .{ .t = .r, .v = .None, .r = sdcb, .d = cur_d }) catch @panic(jify_err_msg);
                var itr = dv_mut.iterator();
                var i: usize = 0;
                while (itr.next()) |dp| {
                    s.append(ma, .{ .t = .v, .v = dp.value_ptr.*, .r = "", .d = child_dd }) catch @panic(jify_err_msg);
                    const sdk = if (p)
                        std.fmt.allocPrint(ma, "\"{s}\": ", .{dp.key_ptr.*}) catch @panic(jify_err_msg)
                    else
                        std.fmt.allocPrint(ma, "\"{s}\":", .{dp.key_ptr.*}) catch @panic(jify_err_msg);
                    s.append(ma, .{ .t = .r, .v = .None, .r = sdk, .d = child_dd }) catch @panic(jify_err_msg);
                    if (i < dpl_len - 1) {
                        var sd_el_sep: []const u8 = ",";
                        if (p) {
                            var st = ma.alloc(u8, 2 + child_dd * 4) catch @panic(jify_err_msg);
                            st[0] = ',';
                            st[1] = '\n';
                            @memset(st[2..], ' ');
                            sd_el_sep = st;
                        }
                        s.append(ma, .{ .t = .r, .v = .None, .r = sd_el_sep, .d = child_dd }) catch @panic(jify_err_msg);
                    }
                    i += 1;
                }
                var sdob: []const u8 = "{";
                if (p) {
                    var st = ma.alloc(u8, 2 + child_dd * 4) catch @panic(jify_err_msg);
                    st[0] = '{';
                    st[1] = '\n';
                    @memset(st[2..], ' ');
                    sdob = st;
                }
                s.append(ma, .{ .t = .r, .v = .None, .r = sdob, .d = child_dd }) catch @panic(jify_err_msg);
                continue;
            },
        }
    }
    return r.toOwnedSlice(gpa) catch @panic(jify_err_msg);
}

pub fn print(va: anytype) void {
    const gpa = global_allocator.?;
    const io = global_io.?;
    const stdout_file = std.Io.File.stdout();
    inline for (va) |arg| {
        const T = @TypeOf(arg);
        if (T == []const u8) {
            stdout_file.writeStreamingAll(io, arg) catch {};
            gpa.free(arg);
        } else if (T == Type) {
            switch (arg) {
                .String => |s| stdout_file.writeStreamingAll(io, s) catch {},
                else => {
                    const s = json_stringify(arg, .{});
                    defer gpa.free(s);
                    stdout_file.writeStreamingAll(io, s) catch {};
                },
            }
        } else if (T == *const [arg.len:0]u8 or T == []u8) {
            stdout_file.writeStreamingAll(io, arg) catch {};
        }
    }
    stdout_file.writeStreamingAll(io, "\n") catch {};
}
