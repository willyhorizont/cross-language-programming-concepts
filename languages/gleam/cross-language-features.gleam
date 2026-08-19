import gleam/io
import willyhorizont/runtime/xl

pub fn main() {
    // 1. support lambda as value, or has workaround
    let say_hello = xl.init_lambda(fn(va) {
        case va {
            [xl.Lambda(callback)] -> {
                io.println("hello")
                callback([])
                xl.init_none()
            }
            _ -> panic as "Error: Invalid arguments."
        }
    })
    let _ = xl.call(say_hello, [xl.init_lambda(fn(_) {
        io.println("world")
        xl.init_none()
    })])
    let create_multiplier = xl.init_lambda(fn(va) {
        case va {
            [xl.Int(aa)] -> {
                xl.init_lambda(fn(va) {
                    case va {
                        [xl.Int(bb)] -> xl.init_int(aa * bb)
                        _ -> panic as "Error: Invalid arguments."
                    }
                })
            }
            _ -> panic as "Error: Invalid arguments."
        }
    })
    let multiply_by_two = xl.call(create_multiplier, [xl.init_int(2)])
    io.println("multiply_by_two(10): " <> xl.to_string(xl.call(multiply_by_two, [xl.init_int(10)])))
    let multiply_by_eight = xl.call(create_multiplier, [xl.init_int(8)])
    io.println("multiply_by_eight(4): " <> xl.to_string(xl.call(multiply_by_eight, [xl.init_int(4)])))
    io.println("multiply_by_two(8): " <> xl.to_string(xl.call(multiply_by_two, [xl.init_int(8)])))

    // 2. support dynamic-typed value, or has workaround
    let xl_list = xl.init_list([
        xl.init_none(),
        xl.init_bool(True),
        xl.init_bool(False),
        xl.init_string("foo"),
        xl.init_int(0),
        xl.init_int(-123),
        xl.init_float(123.789),
        xl.init_float(-123.789),
        xl.init_list([xl.init_int(1), xl.init_int(2), xl.init_int(3)]),
        xl.init_dict([#("foo", xl.init_string("bar"))]),
        xl.init_lambda(fn(va) {
            case va {
                [xl.Int(aa), xl.Int(bb)] -> xl.init_int(aa * bb)
                _ -> panic as "Error: Invalid arguments."
            }
        }),
    ])
    io.println("xl_list: " <> xl.json_stringify([xl_list]))
    io.println("xl_list: " <> xl.json_stringify([xl_list, xl.init_dict([#("pretty", xl.init_bool(True))])]))
    let xl_dict = xl.init_dict([
        #("xl_none", xl.init_none()),
        #("xl_bool_true", xl.init_bool(True)),
        #("xl_bool_false", xl.init_bool(False)),
        #("xl_string", xl.init_string("foo")),
        #("xl_int_positive", xl.init_int(0)),
        #("xl_int_negative", xl.init_int(-123)),
        #("xl_float_positive", xl.init_float(123.789)),
        #("xl_float_negative", xl.init_float(-123.789)),
        #("xl_list", xl.init_list([xl.init_int(1), xl.init_int(2), xl.init_int(3)])),
        #("xl_dict", xl.init_dict([#("foo", xl.init_string("bar"))])),
        #("xl_lambda", xl.init_lambda(fn(va) {
            case va {
                [xl.Int(aa), xl.Int(bb)] -> xl.init_int(aa * bb)
                _ -> panic as "Error: Invalid arguments."
            }
        })),
    ])
    io.println("xl_dict: " <> xl.json_stringify([xl_dict]))
    io.println("xl_dict: " <> xl.json_stringify([xl_dict, xl.init_dict([#("pretty", xl.init_bool(True))])]))
}
