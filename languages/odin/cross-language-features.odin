#+feature dynamic-literals
package main

import "core:fmt"
import "core:strings"
import xl "willyhorizont/runtime"

main :: proc() {
    /*
    1. support function as value
    */
    say_hello := xl.Closure{
        state = nil,
        call = proc(self: ^xl.Closure, varargs: ..xl.Type) -> xl.Type {
            callback_function := varargs[0].(xl.Closure)
            fmt.println("hello")
            callback_function.call(&callback_function)
            return nil
        },
    }
    say_hello.call(&say_hello, xl.Closure{
        state = nil,
        call = proc(self: ^xl.Closure, varargs: ..xl.Type) -> xl.Type {
            fmt.println("world")
            return nil
        },
    })
    free(say_hello.state)

    create_multiplier := xl.Closure{
        state = nil,
        call = proc(self: ^xl.Closure, varargs: ..xl.Type) -> xl.Type {
            aa := varargs[0].(xl.Int)

            current_state := new(struct { aa: xl.Int })
            current_state.aa = aa

            return xl.Closure{
                state = current_state,
                call  = proc(self: ^xl.Closure, varargs: ..xl.Type) -> xl.Type {
                    bb := varargs[0].(xl.Int)

                    current_state := (^struct { aa: xl.Int })(self.state)

                    return xl.Int(current_state.aa * bb)
                },
            }
        },
    }
    multiply_by_two := create_multiplier.call(&create_multiplier, 2).(xl.Closure)
    fmt.println(strings.concatenate([]string{"multiply_by_two(10): ", xl.to_odin_string(multiply_by_two.call(&multiply_by_two, 10))}))
    multiply_by_eight := create_multiplier.call(&create_multiplier, 8).(xl.Closure)
    fmt.println(strings.concatenate([]string{"multiply_by_eight(4): ", xl.to_odin_string(multiply_by_eight.call(&multiply_by_eight, 4))}))
    fmt.println(strings.concatenate([]string{"multiply_by_two(8): ", xl.to_odin_string(multiply_by_two.call(&multiply_by_two, 8))}))
    free(multiply_by_two.state)
    free(multiply_by_eight.state)

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
            state = nil,
            call = proc(self: ^xl.Closure, varargs: ..xl.Type) -> xl.Type {
                aa := varargs[0].(xl.Int)
                bb := varargs[1].(xl.Int)
                return xl.Int(aa * bb)
            },
        },
    }
    defer delete(xl_list)
    fmt.println(strings.concatenate([]string{"xl_list: ", xl.xl_json_stringify(xl_list)}))
    fmt.println(strings.concatenate([]string{"xl_list: ", xl.xl_json_stringify(xl_list, {pretty = true})}))
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
            state = nil,
            call = proc(self: ^xl.Closure, varargs: ..xl.Type) -> xl.Type {
                aa := varargs[0].(xl.Int)
                bb := varargs[1].(xl.Int)
                return xl.Int(aa * bb)
            },
        },
    }
    defer delete(xl_dict)
    fmt.println(strings.concatenate([]string{"xl_dict: ", xl.xl_json_stringify(xl_dict)}))
    fmt.println(strings.concatenate([]string{"xl_dict: ", xl.xl_json_stringify(xl_dict, {pretty = true})}))
}
