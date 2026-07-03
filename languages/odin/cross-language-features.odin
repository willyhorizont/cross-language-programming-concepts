#+feature dynamic-literals
package main

import "core:fmt"
import "core:strings"
import xl "runtime/willyhorizont"

main :: proc() {
    /*
    1. support function as value
    */
    say_hello := xl.XlClosure{
        state = nil,
        call = proc(self: ^xl.XlClosure, varargs: ..xl.CrossType) -> xl.CrossType {
            callback_function := varargs[0].(xl.XlClosure)
            fmt.println("hello")
            callback_function.call(&callback_function)
            return nil
        },
    }
    say_hello.call(&say_hello, xl.XlClosure{
        state = nil,
        call = proc(self: ^xl.XlClosure, varargs: ..xl.CrossType) -> xl.CrossType {
            fmt.println("world")
            return nil
        },
    })
    free(say_hello.state)

    create_multiplier := xl.XlClosure{
        state = nil,
        call = proc(self: ^xl.XlClosure, varargs: ..xl.CrossType) -> xl.CrossType {
            aa := varargs[0].(xl.XlInt)

            current_state := new(struct { aa: xl.XlInt })
            current_state.aa = aa

            return xl.XlClosure{
                state = current_state,
                call  = proc(self: ^xl.XlClosure, varargs: ..xl.CrossType) -> xl.CrossType {
                    bb := varargs[0].(xl.XlInt)

                    current_state := (^struct { aa: xl.XlInt })(self.state)

                    return xl.XlInt(current_state.aa * bb)
                },
            }
        },
    }
    multiply_by_two := create_multiplier.call(&create_multiplier, 2).(xl.XlClosure)
    fmt.println(strings.concatenate([]string{"multiply_by_two(10): ", xl.to_odin_string(multiply_by_two.call(&multiply_by_two, 10))}))
    multiply_by_eight := create_multiplier.call(&create_multiplier, 8).(xl.XlClosure)
    fmt.println(strings.concatenate([]string{"multiply_by_eight(4): ", xl.to_odin_string(multiply_by_eight.call(&multiply_by_eight, 4))}))
    fmt.println(strings.concatenate([]string{"multiply_by_two(8): ", xl.to_odin_string(multiply_by_two.call(&multiply_by_two, 8))}))
    free(multiply_by_two.state)
    free(multiply_by_eight.state)

    /*
    2. support dynamic-typed value, or has workaround
    */
    xl_list := xl.XlList{
        nil,
        xl.to_xl(true),
        xl.to_xl(false),
        xl.to_xl("foo"),
        xl.to_xl(0),
        xl.to_xl(-123),
        xl.to_xl(123.789),
        xl.to_xl(-123.789),
        xl.CrossType(xl.XlList{1, 2, 3}),
        xl.CrossType(xl.XlDict{"foo" = "bar"}),
        xl.CrossType(xl.XlClosure{
            state = nil,
            call = proc(self: ^xl.XlClosure, varargs: ..xl.CrossType) -> xl.CrossType {
                aa := varargs[0].(xl.XlInt)
                bb := varargs[1].(xl.XlInt)
                return xl.XlInt(aa * bb)
            },
        }),
    }
    defer delete(xl_list)
    fmt.println(strings.concatenate([]string{"xl_list: ", xl.to_odin_string(xl_list)}))
    fmt.println(strings.concatenate([]string{"xl_list: ", xl.xl_json_stringify(xl_list)}))
    fmt.println(strings.concatenate([]string{"xl_list: ", xl.xl_json_stringify(xl_list, {pretty = true})}))
    xl_dict := xl.XlDict{
        "xl_none" = nil,
        "xl_bool_true" = true,
        "xl_bool_false" = false,
        "xl_string" = "foo",
        "xl_int_positive" = 0,
        "xl_int_negative" = -123,
        "xl_float_positive" = 123.789,
        "xl_float_negative" = -123.789,
        "xl_list" = xl.CrossType(xl.XlList{1, 2, 3}),
        "xl_dict" = xl.CrossType(xl.XlDict{"foo" = "bar"}),
        "xl_closure" = xl.CrossType(xl.XlClosure{
            state = nil,
            call = proc(self: ^xl.XlClosure, varargs: ..xl.CrossType) -> xl.CrossType {
                aa := varargs[0].(xl.XlInt)
                bb := varargs[1].(xl.XlInt)
                return xl.XlInt(aa * bb)
            },
        }),
    }
    defer delete(xl_dict)
    fmt.println(strings.concatenate([]string{"xl_dict: ", xl.to_odin_string(xl_dict)}))
    fmt.println(strings.concatenate([]string{"xl_dict: ", xl.xl_json_stringify(xl_dict)}))
    fmt.println(strings.concatenate([]string{"xl_dict: ", xl.xl_json_stringify(xl_dict, {pretty = true})}))
}
