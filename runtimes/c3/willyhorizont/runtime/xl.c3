module willyhorizont::runtime::xl;

import std::io;
import std::core::mem;
import std::collections::map;
import std::collections::list;

alias None = void*;
alias Bool = bool;
alias Int = int;
alias Float = float;
alias List = list::List{Type*};
alias Dict = map::HashMap{String, Type*};
alias Lambda = fn Type* (Type* ctx_ref, Type* va);

enum Types @public
{
    NONE,
    BOOL,
    STRING,
    INT,
    FLOAT,
    LIST,
    DICT,
    LAMBDA,
    ITERATOR
}

struct Type @public
{
    Types type;
    union
    {
        None none_value;
        Bool bool_value;
        String string_value;
        Int int_value;
        Float float_value;
        List* list_ref;
        Dict* dict_ref;
        Lambda lambda_value;
        Iterator* iterator_ref;
    }
    Type* ctx_ref;
}

struct Pair
{
    String key;
    Type* value;
}

struct Iterator @public
{
    Type* list_ref;
    sz index;
}

fn Type* init_none() @public
{
    Type* r = mem::new(Type);
    Type n;
    n.type = Types.NONE;
    n.none_value = null;
    *r = n;
    return r;
}

fn Type* init_bool(Bool v) @public
{
    Type* r = mem::new(Type);
    Type b;
    b.type = Types.BOOL;
    b.bool_value = v;
    *r = b;
    return r;
}

fn Type* init_string(String v) @public
{
    Type* r = mem::new(Type);
    Type s;
    s.type = Types.STRING;
    s.string_value = v;
    *r = s;
    return r;
}

fn Type* init_int(Int v) @public
{
    Type* r = mem::new(Type);
    Type i;
    i.type = Types.INT;
    i.int_value = v;
    *r = i;
    return r;
}

fn Type* init_float(Float v) @public
{
    Type* r = mem::new(Type);
    Type f;
    f.type = Types.FLOAT;
    f.float_value = v;
    *r = f;
    return r;
}

fn Type* init_list(Type*... ell) @public
{
    Type* r = mem::new(Type);
    List* lr = mem::new(List);
    lr.init(mem);
    foreach (el : ell)
    {
        lr.push(el);
    }
    Type l;
    l.type = Types.LIST;
    l.list_ref = lr;
    *r = l;
    return r;
}

fn Type* init_dict(Pair... pl) @public
{
    Type* r = mem::new(Type);
    Dict* dr = mem::new(Dict);
    dr.init(mem);
    foreach (p : pl)
    {
        dr.set(p.key, p.value);
    }
    Type d;
    d.type = Types.DICT;
    d.dict_ref = dr;
    *r = d;
    return r;
}

macro Type* init_lambda(c_ref, Type* ctx_ref = null) @public
{
    Type* r = mem::new(Type);
    Type c;
    c.type = Types.LAMBDA;
    c.lambda_value = (xl::Lambda)c_ref;
    c.ctx_ref = ctx_ref;
    *r = c;
    return r;
}

macro Type* Type.call(Type* this, va)
{
    if (this == null || this.type != Types.LAMBDA || this.lambda_value == null)
    {
        unreachable("XlRuntimeError: Invalid arguments.");
    }
    Type* ctx_ref = null;
    if (this.ctx_ref != null) {
        ctx_ref = this.ctx_ref;
    }
    return this.lambda_value(ctx_ref, init_list(va));
}

fn Type* get(Type* d, String k) @public
{
    if (d == null || d.type != Types.DICT || d.dict_ref == null)
    {
        unreachable("XlRuntimeError: Invalid arguments.");
    }
    xl::Dict* d_ref = d.dict_ref;
    return d_ref.get(k)!!;
}

fn Type* iter(Type* l) @public
{
    if (l == null || l.type != Types.LIST || l.list_ref == null)
    {
        unreachable("XlRuntimeError: Invalid arguments.");
    }
    Iterator* itrr = mem::new(Iterator);
    itrr.list_ref = l;
    itrr.index = 0;
    Type* r = mem::new(Type);
    Type itr;
    itr.type = Types.ITERATOR;
    itr.iterator_ref = itrr;
    *r = itr;
    return r;
}

fn Type* next(Type* itr) @public
{
    if (itr == null || itr.type != Types.ITERATOR || itr.iterator_ref == null)
    {
        unreachable("XlRuntimeError: Invalid arguments.");
    }
    Iterator* itrr = itr.iterator_ref;
    if (itrr.index >= itrr.list_ref.list_ref.len())
    {
        return init_none();
    }
    Type* r = itrr.list_ref.list_ref.get(itrr.index);
    itrr.index += 1;
    return r;
}

fn void free_memory(Type* a) @public
{
    if (a == null) return;
    switch (a.type)
    {
        case LIST:
            if (a.list_ref != null)
            {
                foreach (el : *a.list_ref)
                {
                    free_memory(el);
                }
                a.list_ref.free();
                mem::free(a.list_ref);
            }
            break;
        case DICT:
            if (a.dict_ref != null)
            {
                foreach (p : a.dict_ref.iter())
                {
                    free_memory(p.value);
                }
                a.dict_ref.free();
                mem::free(a.dict_ref);
            }
            break;
        case LAMBDA:
            if (a.ctx_ref != null)
            {
                free_memory(a.ctx_ref);
            }
            break;
        case ITERATOR:
            if (a.iterator_ref != null)
            {
                mem::free(a.iterator_ref);
            }
            break;
        default:
            break;
    }
    mem::free(a);
}

fn String join(String... ss) @public
{
    usz s_len = 0;
    foreach (s : ss) {
        s_len += s.len;
    }
    if (s_len == 0) return "";
    char* sb = (char*)mem::new_array(char, (sz)(s_len + 1));
    usz offset = 0;
    foreach (s : ss) {
        if (s.len > 0) {
            mem::copy(sb + offset, s.ptr, s.len);
            offset += s.len;
        }
    }
    sb[s_len] = '\0';
    return (String)sb[0..s_len];
}

fn String String.repeat(String this, int count)
{
    if (count <= 0 || this.len == 0) {
        return "";
    }
    usz s_len = this.len * (usz)count;
    char* sb = (char*)mem::new_array(char, (sz)s_len);
    usz offset = 0;
    for (int i = 0; i < count; i += 1) {
        mem::copy(sb + offset, this.ptr, this.len);
        offset += this.len;
    }
    return (String)sb[0..s_len];
}

fn void escape_string(DString* r, String s)
{
    for (usz i = 0; i < s.len; i += 1)
    {
        char c = s.ptr[i];
        switch (c)
        {
            case '\\':
                r.append("\\\\");
                break;
            case '"':
                r.append("\\\"");
                break;
            case '\n':
                r.append("\\n"); 
                break;
            case '\r':
                r.append("\\r"); 
                break;
            case '\t':
                r.append("\\t"); 
                break;
            default:
                r.appendf("%c", c);
                break;
        }
    }
}

enum JifyStkElT { V, R }

struct JifyStkEl
{
    JifyStkElT t;
    Type* v;      
    String r;  
    int d;
}

fn String json_stringify(Type* a, bool pretty = false) @public
{
    bool p = pretty;
    String t = " ".repeat(4);
    list::List{JifyStkEl} s;
    s.init(mem);
    defer s.free();
    s.push({ .t = JifyStkElT.V, .v = a, .r = "", .d = 0 });
    DString r;
    defer r.free();
    while (s.len() > 0)
    {
        JifyStkEl c = s.get(s.len() - 1);
        (void)s.pop();
        if (c.t == JifyStkElT.R)
        {
            r.append(c.r);
            continue;
        }
        Type* v = c.v;
        int cur_d = c.d;
        if (v == null || v.type == Types.NONE)
        {
            r.append("null");
            continue;
        }
        switch (v.type)
        {
            case BOOL:
                r.append(v.bool_value ? "true" : "false");
                break;
            case STRING:
                r.append("\"");
                escape_string(&r, v.string_value);
                r.append("\"");
                break;
            case INT:
                r.appendf("%d", v.int_value);
                break;
            case FLOAT:
                r.appendf("%g", v.float_value);
                break;
            case LAMBDA:
                r.append("\"[object Function]\"");
                break;
            case LIST:
                if (v.list_ref == null || v.list_ref.len() == 0)
                {
                    r.append("[]");
                    continue;
                }
                int child_dl = cur_d + 1;
                s.push((JifyStkEl){
                    .t = JifyStkElT.R,
                    .v = null,
                    .r = p ? join("\n", t.repeat(cur_d), "]") : "]",
                    .d = cur_d,
                });
                for (sz i = v.list_ref.len() - 1; i >= 0; i -= 1)
                {
                    s.push((JifyStkEl){
                        .t = JifyStkElT.V,
                        .v = v.list_ref.get(i),
                        .r = "",
                        .d = child_dl,
                    });
                    if (i > 0)
                    {
                        s.push((JifyStkEl){
                            .t = JifyStkElT.R,
                            .v = null,
                            .r = p ? join(",\n", t.repeat(child_dl)) : ",",
                            .d = child_dl
                        });
                    }
                }
                s.push((JifyStkEl){
                    .t = JifyStkElT.R,
                    .v = null,
                    .r = p ? join("[\n", t.repeat(child_dl)) : "[",
                    .d = child_dl,
                });
                break;
            case DICT:
                if (v.dict_ref == null || v.dict_ref.len() == 0)
                {
                    r.append("{}");
                    continue;
                }
                int child_dd = cur_d + 1;
                s.push((JifyStkEl){
                    .t = JifyStkElT.R,
                    .v = null,
                    .r = p ? join("\n", t.repeat(cur_d), "}") : "}",
                    .d = cur_d,
                });
                list::List{Pair} dpl;
                dpl.init(mem);
                defer dpl.free();
                foreach (i, del : v.dict_ref.iter())
                {
                    dpl.push({ del.key, del.value });
                }
                for (sz i = (sz)dpl.len() - 1; i >= 0; i -= 1)
                {
                    Pair del = dpl.get(i);
                    s.push((JifyStkEl){
                        .t = JifyStkElT.V,
                        .v = del.value,
                        .r = "",
                        .d = child_dd,
                    });
                    s.push((JifyStkEl){
                        .t = JifyStkElT.R,
                        .v = null,
                        .r = p ? join("\"", del.key, "\": ") : join("\"", del.key, "\":"),
                        .d = child_dd,
                    });
                    if (i > 0)
                    {
                        s.push((JifyStkEl){
                            .t = JifyStkElT.R,
                            .v = null,
                            .r = p ? join(",\n", t.repeat(child_dd)) : ",",
                            .d = child_dd,
                        });
                    }
                }
                s.push((JifyStkEl){
                    .t = JifyStkElT.R,
                    .v = null,
                    .r = p ? join("{\n", t.repeat(child_dd)) : "{",
                    .d = child_dd,
                });
                break;
            default:
                r.append("\"[object [\\\"C3 Object\\\"]]\"");
                break;
        }
    }
    return join(r.str_view());
}

fn Bool to_bool(Type* a) @public
{
    if (a == null) return false;
    switch (a.type)
    {
        case NONE:
            return false;
        case BOOL:
            return a.bool_value;
        case INT:
            return a.int_value != 0;
        case FLOAT:
            return a.float_value != 0.0;
        case STRING:
            return a.string_value.len > 0;
        case LIST:
            return a.list_ref != null && a.list_ref.len() > 0;
        case DICT:
            return a.dict_ref != null && a.dict_ref.len() > 0;
        default:
            return true;
    }
}

fn String to_string(Type* a) @public
{
    if (a == null) return "null";
    switch (a.type)
    {
        case NONE:
            return "null";
        case BOOL:
            return a.bool_value ? "true" : "false";
        case INT:
            return string::format(mem, "%d", a.int_value);
        case FLOAT:
            return string::format(mem, "%f", a.float_value);
        case STRING:
            return a.string_value;
        case LIST:
            return json_stringify(a);
        case DICT:
            return json_stringify(a);
        case LAMBDA:
            return "[object Function]";
        default:
            return "null";
    }
}

fn Int to_int(Type* a) @public
{
    if (a == null) return 0;
    switch (a.type)
    {
        case NONE:
            return 0;
        case BOOL:
            return a.bool_value ? 1 : 0;
        case INT:
            return a.int_value;
        case FLOAT:
            return (Int)a.float_value;
        case STRING:
            return (Int)a.string_value.to_int(10)!!;
        default:
            return 0;
    }
}

fn Float to_float(Type* a) @public
{
    if (a == null) return 0.0;
    switch (a.type)
    {
        case NONE:
            return 0.0;
        case BOOL:
            return a.bool_value ? 1.0 : 0.0;
        case INT:
            return (Float)a.int_value;
        case FLOAT:
            return a.float_value;
        case STRING:
            return (Float)a.string_value.to_float()!!;
        default:
            return 0.0;
    }
}

macro printn(...) @public
{
    $for var $i = 0; $i < $vaarg.len; $i += 1:
        $switch $Typeof($vaarg[$i]):
            $case String:
                io::print((String)$vaarg[$i]);
                $if $stringify($vaarg[$i])[0] != '"':
                    mem::free(($vaarg[$i]).ptr);
                $endif
            $case Type*:
                Type* $t = (Type*)$vaarg[$i];
                if ($t != null) {
                    switch ($t.type) {
                        case BOOL:
                            io::print($t.bool_value ? "true" : "false");
                            break;
                        case STRING:
                            io::print($t.string_value);
                            break;
                        case INT:
                            io::printf("%d", $t.int_value);
                            break;
                        case FLOAT:
                            io::printf("%g", $t.float_value);
                            break;
                        default:
                            io::print("[object Object]");
                            break;
                    }
                    free_memory($t);
                }
            $default:
                io::print($vaarg[$i]);
        $endswitch
    $endfor
    io::printn("");
}
