#+feature dynamic-literals
package main

import "core:fmt"
import "core:strings"
import W "runtime/willyhorizont"

main :: proc() {
    /*
    1. support function as value
    */
    say_hello := W.XlClosure{
        state = nil,
        call = proc(self: ^W.XlClosure, varargs: ..W.CrossType) -> W.CrossType {
            callback_function := varargs[0].(W.XlClosure)
            fmt.println("hello")
            callback_function.call(&callback_function)
            return nil
        },
    }
    say_hello.call(&say_hello, W.XlClosure{
        state = nil,
        call = proc(self: ^W.XlClosure, varargs: ..W.CrossType) -> W.CrossType {
            fmt.println("world")
            return nil
        },
    })
    free(say_hello.state)

    create_multiplier := W.XlClosure{
        state = nil,
        call = proc(self: ^W.XlClosure, varargs: ..W.CrossType) -> W.CrossType {
            aa := varargs[0].(W.XlInt)

            current_state := new(struct { aa: W.XlInt })
            current_state.aa = aa

            return W.XlClosure{
                state = current_state,
                call  = proc(self: ^W.XlClosure, varargs: ..W.CrossType) -> W.CrossType {
                    bb := varargs[0].(W.XlInt)

                    current_state := (^struct { aa: W.XlInt })(self.state)

                    return W.XlInt(current_state.aa * bb)
                },
            }
        },
    }
    multiply_by_two := create_multiplier.call(&create_multiplier, 2).(W.XlClosure)
    fmt.println(strings.concatenate([]string{"multiply_by_two(10): ", W.to_odin_string(multiply_by_two.call(&multiply_by_two, 10))}))
    multiply_by_eight := create_multiplier.call(&create_multiplier, 8).(W.XlClosure)
    fmt.println(strings.concatenate([]string{"multiply_by_eight(4): ", W.to_odin_string(multiply_by_eight.call(&multiply_by_eight, 4))}))
    fmt.println(strings.concatenate([]string{"multiply_by_two(8): ", W.to_odin_string(multiply_by_two.call(&multiply_by_two, 8))}))
    free(multiply_by_two.state)
    free(multiply_by_eight.state)

    /* 
    2. support dynamic-typed value, or has workaround
    */
    xl_list := W.XlList{
        nil,
        W.to_xl(true),
        W.to_xl(false),
        W.to_xl("foo"),
        W.to_xl(0),
        W.to_xl(-123),
        W.to_xl(123.789),
        W.to_xl(-123.789),
        W.CrossType(W.XlList{1, 2, 3}),
        W.CrossType(W.XlDict{"foo" = "bar"}),
        W.CrossType(W.XlClosure{
            state = nil,
            call = proc(self: ^W.XlClosure, varargs: ..W.CrossType) -> W.CrossType {
                aa := varargs[0].(W.XlInt)
                bb := varargs[1].(W.XlInt)
                return W.XlInt(aa * bb)
            },
        }),
    }
    defer delete(xl_list)
    fmt.println(strings.concatenate([]string{"xl_list: ", W.to_odin_string(xl_list)}))
    fmt.println(strings.concatenate([]string{"xl_list: ", W.xl_json_stringify(xl_list)}))
    fmt.println(strings.concatenate([]string{"xl_list: ", W.xl_json_stringify(xl_list, {pretty = true})}))
    xl_dict := W.XlDict{
        "xl_none" = nil,
        "xl_bool_true" = true,
        "xl_bool_false" = false,
        "xl_string" = "foo",
        "xl_int_positive" = 0,
        "xl_int_negative" = -123,
        "xl_float_positive" = 123.789,
        "xl_float_negative" = -123.789,
        "xl_list" = W.CrossType(W.XlList{1, 2, 3}),
        "xl_dict" = W.CrossType(W.XlDict{"foo" = "bar"}),
        "xl_closure" = W.CrossType(W.XlClosure{
            state = nil,
            call = proc(self: ^W.XlClosure, varargs: ..W.CrossType) -> W.CrossType {
                aa := varargs[0].(W.XlInt)
                bb := varargs[1].(W.XlInt)
                return W.XlInt(aa * bb)
            },
        }),
    }
    defer delete(xl_dict)
    fmt.println(strings.concatenate([]string{"xl_dict: ", W.to_odin_string(xl_dict)}))
    fmt.println(strings.concatenate([]string{"xl_dict: ", W.xl_json_stringify(xl_dict)}))
    fmt.println(strings.concatenate([]string{"xl_dict: ", W.xl_json_stringify(xl_dict, {pretty = true})}))
}
