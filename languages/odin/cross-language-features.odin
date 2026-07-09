#+feature dynamic-literals
package main
import "core:fmt"
import "core:strings"
import xl "willyhorizont/runtime"

main :: proc() {
    glb_scp := xl.reg_scope(nil)
    /*
    1. support closure as value, or has workaround
    */
    say_hello := xl.Closure{
        call = proc(self: ^xl.Closure, va: ..xl.Type) -> xl.Type {
            itr := xl.iter(..va) 
            callback_function := xl.next(&itr).(xl.Closure)
            fmt.println("hello")
            callback_function.call(&callback_function)
            return nil
        },
    }
    say_hello.call(&say_hello, xl.Closure{
        call = proc(self: ^xl.Closure, va: ..xl.Type) -> xl.Type {
            fmt.println("world")
            return nil
        },
    })
    create_multiplier := xl.Closure{
        value = glb_scp, 
        call = proc(self: ^xl.Closure, va: ..xl.Type) -> xl.Type {
            itr := xl.iter(..va) 
            aa := xl.next(&itr)
            par_scp := (^xl.Scope)(self.value)
            return xl.Closure{
                value = xl.reg_scope(par_scp, xl.Dict{
                    "aa" = aa.(xl.Int),
                }), 
                call  = proc(self: ^xl.Closure, va: ..xl.Type) -> xl.Type {
                    itr := xl.iter(..va)
                    bb := xl.next(&itr)
                    par_scp := (^xl.Scope)(self.value)
                    aa := xl.get_var(par_scp, "aa")
                    return xl.Int(aa.(xl.Int) * bb.(xl.Int))
                },
            }
        },
    }
    multiply_by_two := create_multiplier.call(&create_multiplier, 2).(xl.Closure)
    multiply_by_eight := create_multiplier.call(&create_multiplier, 8).(xl.Closure)
    fmt.printfln("multiply_by_two(10): %d", multiply_by_two.call(&multiply_by_two, 10).(xl.Int))
    fmt.printfln("multiply_by_eight(4): %d", multiply_by_eight.call(&multiply_by_eight, 4).(xl.Int))
    fmt.printfln("multiply_by_two(8): %d", multiply_by_two.call(&multiply_by_two, 8).(xl.Int))

    /*
    2. support dynamic-typed value, or has workaround
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
        xl.Closure{
            call = proc(self: ^xl.Closure, va: ..xl.Type) -> xl.Type {
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
        "xl_closure" = xl.Closure{
            call = proc(self: ^xl.Closure, va: ..xl.Type) -> xl.Type {
                itr := xl.iter(..va) 
                aa := xl.next(&itr).(xl.Int)
                bb := xl.next(&itr).(xl.Int)
                return xl.Int(aa * bb)
            },
        },
    }
    fmt.println(strings.concatenate([]string{"xl_dict: ", xl.json_stringify(xl_dict)}, context.temp_allocator))
    fmt.println(strings.concatenate([]string{"xl_dict: ", xl.json_stringify(xl_dict, {pretty = true})}, context.temp_allocator))

    free(say_hello.value)
    xl.unreg_scope((^xl.Scope)(multiply_by_two.value))
    xl.unreg_scope((^xl.Scope)(multiply_by_eight.value))
    delete(xl_list)
    delete(xl_dict)
    xl.unreg_scope(glb_scp)
}
