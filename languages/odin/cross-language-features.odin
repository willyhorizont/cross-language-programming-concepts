#+feature dynamic-literals
package main
import "core:fmt"
import "core:strings"
import "core:mem"
import "core:mem/virtual"
import "willyhorizont/runtime/xl"

main :: proc() {
    arena: virtual.Arena
    err := virtual.arena_init_growing(&arena)
    if err != nil {
        fmt.eprintln("Error: Failed initialize virtual memory arena.")
        return
    }
    defer virtual.arena_destroy(&arena) 
    context.allocator = virtual.arena_allocator(&arena)

    global_ctx := xl.reg_ctx(nil)
    /*
    # -- 1. support lambda as value, or has workaround
    */
    say_hello := xl.init_lambda(
        ctx = global_ctx,
        value = proc(self: ^xl.Lambda, va: ..xl.Type) -> xl.Type {
            itr := xl.iter(..va)
            callback := xl.next(&itr)
            fmt.println("hello")
            xl.call(callback)
            return nil
        },
    )
    xl.call(say_hello, xl.init_lambda(
        ctx = global_ctx,
        value = proc(self: ^xl.Lambda, va: ..xl.Type) -> xl.Type {
            fmt.println("world")
            return nil
        },
    ))
    create_multiplier := xl.init_lambda(
        ctx = global_ctx,
        value = proc(self: ^xl.Lambda, va: ..xl.Type) -> xl.Type {
            itr := xl.iter(..va)
            aa := xl.next(&itr)
            return xl.init_lambda(
                ctx = xl.reg_ctx((^xl.Ctx)(self.ctx), xl.Dict{
                    "aa" = aa,
                }),
                value = proc(self: ^xl.Lambda, va: ..xl.Type) -> xl.Type {
                    itr := xl.iter(..va)
                    bb := xl.next(&itr)
                    aa := xl.get_ctx((^xl.Ctx)(self.ctx), "aa")
                    return xl.init_int(aa.(xl.Int) * bb.(xl.Int))
                },
            )
        },
    )
    multiply_by_two := xl.call(create_multiplier, xl.init_int(2))
    multiply_by_eight := xl.call(create_multiplier, xl.init_int(8))
    fmt.println(strings.concatenate([]string{"multiply_by_two(10): ", xl.json_stringify(xl.call(multiply_by_two, xl.init_int(10)))}, context.temp_allocator))
    fmt.println(strings.concatenate([]string{"multiply_by_eight(4): ", xl.json_stringify(xl.call(multiply_by_eight, xl.init_int(4)))}, context.temp_allocator))
    fmt.println(strings.concatenate([]string{"multiply_by_two(8): ", xl.json_stringify(xl.call(multiply_by_two, xl.init_int(8)))}, context.temp_allocator))

    /*
    # -- 2. support dynamic-typed value, or has workaround
    */
    xl_list := xl.init_list(
        nil,
        xl.init_bool(true),
        xl.init_bool(false),
        xl.init_string("foo"),
        xl.init_int(0),
        xl.init_int(-123),
        xl.init_float(123.789),
        xl.init_float(-123.789),
        xl.init_list(xl.init_int(1), xl.init_int(2), xl.init_int(3)),
        xl.init_dict(xl.init_pair("foo", xl.init_string("bar"))),
        xl.init_lambda(
            ctx = global_ctx,
            value = proc(self: ^xl.Lambda, va: ..xl.Type) -> xl.Type {
                itr := xl.iter(..va)
                aa := xl.next(&itr)
                bb := xl.next(&itr)
                return xl.init_int(aa.(xl.Int) * bb.(xl.Int))
            },
        ),
    )
    fmt.println(strings.concatenate([]string{"xl_list: ", xl.json_stringify(xl_list)}, context.temp_allocator))
    fmt.println(strings.concatenate([]string{"xl_list: ", xl.json_stringify(xl_list, {pretty = true})}, context.temp_allocator))
    xl_dict := xl.init_dict(
        xl.init_pair("xl_none", nil),
        xl.init_pair("xl_bool_true", xl.init_bool(true)),
        xl.init_pair("xl_bool_false", xl.init_bool(false)),
        xl.init_pair("xl_string", xl.init_string("foo")),
        xl.init_pair("xl_int_positive", xl.init_int(0)),
        xl.init_pair("xl_int_negative", xl.init_int(-123)),
        xl.init_pair("xl_float_positive", xl.init_float(123.789)),
        xl.init_pair("xl_float_negative", xl.init_float(-123.789)),
        xl.init_pair("xl_list", xl.init_list(xl.init_int(1), xl.init_int(2), xl.init_int(3))),
        xl.init_pair("xl_dict", xl.init_dict(xl.init_pair("foo", xl.init_string("bar")))),
        xl.init_pair("xl_lambda", xl.init_lambda(
            ctx = global_ctx,
            value = proc(self: ^xl.Lambda, va: ..xl.Type) -> xl.Type {
                itr := xl.iter(..va)
                aa := xl.next(&itr)
                bb := xl.next(&itr)
                return xl.init_int(aa.(xl.Int) * bb.(xl.Int))
            },
        )),
    )
    fmt.println(strings.concatenate([]string{"xl_dict: ", xl.json_stringify(xl_dict)}, context.temp_allocator))
    fmt.println(strings.concatenate([]string{"xl_dict: ", xl.json_stringify(xl_dict, {pretty = true})}, context.temp_allocator))
}
