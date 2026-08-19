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
    say_hello := xl.Lambda{
        ctx = global_ctx,
        call = proc(self: ^xl.Lambda, va: ..xl.Type) -> xl.Type {
            itr := xl.iter(..va)
            callback := xl.next(&itr).(xl.Lambda)
            fmt.println("hello")
            callback.call(&callback)
            return nil
        },
    }
    say_hello.call(&say_hello, xl.Lambda{
        ctx = global_ctx,
        call = proc(self: ^xl.Lambda, va: ..xl.Type) -> xl.Type {
            fmt.println("world")
            return nil
        },
    })
    create_multiplier := xl.Lambda{
        ctx = global_ctx,
        call = proc(self: ^xl.Lambda, va: ..xl.Type) -> xl.Type {
            itr := xl.iter(..va)
            aa := xl.next(&itr)
            return xl.Lambda{
                ctx = xl.reg_ctx((^xl.Ctx)(self.ctx), xl.Dict{
                    "aa" = aa.(xl.Int),
                }),
                call = proc(self: ^xl.Lambda, va: ..xl.Type) -> xl.Type {
                    itr := xl.iter(..va)
                    bb := xl.next(&itr)
                    aa := xl.get_ctx((^xl.Ctx)(self.ctx), "aa")
                    return xl.Int(aa.(xl.Int) * bb.(xl.Int))
                },
            }
        },
    }
    multiply_by_two := create_multiplier.call(&create_multiplier, 2).(xl.Lambda)
    multiply_by_eight := create_multiplier.call(&create_multiplier, 8).(xl.Lambda)
    fmt.printfln("multiply_by_two(10): %d", multiply_by_two.call(&multiply_by_two, 10).(xl.Int))
    fmt.printfln("multiply_by_eight(4): %d", multiply_by_eight.call(&multiply_by_eight, 4).(xl.Int))
    fmt.printfln("multiply_by_two(8): %d", multiply_by_two.call(&multiply_by_two, 8).(xl.Int))

    /*
    # -- 2. support dynamic-typed value, or has workaround
    */
    xl_list := xl.List{
        nil,
        true,
        false,
        "foo",
        0,
        -123,
        123.789,
        -123.789,
        xl.List{1, 2, 3},
        xl.Dict{"foo" = "bar"},
        xl.Lambda{
            ctx = global_ctx,
            call = proc(self: ^xl.Lambda, va: ..xl.Type) -> xl.Type {
                itr := xl.iter(..va)
                aa := xl.next(&itr).(xl.Int)
                bb := xl.next(&itr).(xl.Int)
                return xl.Int(aa * bb)
            },
        },
    }
    fmt.println(strings.concatenate([]string{"xl_list: ", xl.json_stringify(xl_list)}, context.temp_allocator))
    fmt.println(strings.concatenate([]string{"xl_list: ", xl.json_stringify(xl_list, {pretty = true})}, context.temp_allocator))
    xl_dict := xl.Dict{
        "xl_none" = nil,
        "xl_bool_true" = true,
        "xl_bool_false" = false,
        "xl_string" = "foo",
        "xl_int_positive" = 0,
        "xl_int_negative" = -123,
        "xl_float_positive" = 123.789,
        "xl_float_negative" = -123.789,
        "xl_list" = xl.List{1, 2, 3},
        "xl_dict" = xl.Dict{"foo" = "bar"},
        "xl_lambda" = xl.Lambda{
            ctx = global_ctx,
            call = proc(self: ^xl.Lambda, va: ..xl.Type) -> xl.Type {
                itr := xl.iter(..va)
                aa := xl.next(&itr).(xl.Int)
                bb := xl.next(&itr).(xl.Int)
                return xl.Int(aa * bb)
            },
        },
    }
    fmt.println(strings.concatenate([]string{"xl_dict: ", xl.json_stringify(xl_dict)}, context.temp_allocator))
    fmt.println(strings.concatenate([]string{"xl_dict: ", xl.json_stringify(xl_dict, {pretty = true})}, context.temp_allocator))
}
