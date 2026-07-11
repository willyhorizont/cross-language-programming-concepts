import gleam/io
import willyhorizont/runtime/xl

pub fn main() {
    // 1. support closure as value, or has workaround
    let say_hello = xl.closure(fn(va) {
        case va {
            [xl.Closure(callback_function)] -> {
                io.println("hello")
                callback_function([])
                xl.none()
            }
            _ -> xl.none()
        }
    })
    let _ = xl.call(say_hello, [xl.closure(fn(_) {
        io.println("world")
        xl.none()
    })])
    let create_multiplier = xl.closure(fn(va) {
        case va {
            [xl.Int(aa)] -> {
                xl.closure(fn(va) {
                    case va {
                        [xl.Int(bb)] -> xl.int(aa * bb)
                        _ -> xl.none()
                    }
                })
            }
            _ -> xl.none()
        }
    })
    let multiply_by_two = xl.call(create_multiplier, [xl.int(2)])
    io.println("multiply_by_two(10): " <> xl.to_string(xl.call(multiply_by_two, [xl.int(10)])))
    let multiply_by_eight = xl.call(create_multiplier, [xl.int(8)])
    io.println("multiply_by_eight(4): " <> xl.to_string(xl.call(multiply_by_eight, [xl.int(4)])))
    io.println("multiply_by_two(8): " <> xl.to_string(xl.call(multiply_by_two, [xl.int(8)])))

    // 2. support dynamic-typed value, or has workaround
    let xl_list = xl.list([
        xl.none(),
        xl.bool(True),
        xl.bool(False),
        xl.string("foo"),
        xl.int(0),
        xl.int(-123),
        xl.float(123.789),
        xl.float(-123.789),
        xl.list([xl.int(1), xl.int(2), xl.int(3)]),
        xl.dict([#("foo", xl.string("bar"))]),
        xl.closure(fn(va) {
            case va {
                [xl.Int(aa), xl.Int(bb)] -> xl.int(aa * bb)
                _ -> xl.none()
            }
        }),
    ])
    io.println("xl_list: " <> xl.json_stringify([xl_list]))
    io.println("xl_list: " <> xl.json_stringify([xl_list, xl.dict([#("pretty", xl.bool(True))])]))
    let xl_dict = xl.dict([
        #("xl_none", xl.none()),
        #("xl_bool_true", xl.bool(True)),
        #("xl_bool_false", xl.bool(False)),
        #("xl_string", xl.string("foo")),
        #("xl_int_positive", xl.int(0)),
        #("xl_int_negative", xl.int(-123)),
        #("xl_float_positive", xl.float(123.789)),
        #("xl_float_negative", xl.float(-123.789)),
        #("xl_list", xl.list([xl.int(1), xl.int(2), xl.int(3)])),
        #("xl_dict", xl.dict([#("foo", xl.string("bar"))])),
        #("xl_closure", xl.closure(fn(va) {
            case va {
                [xl.Int(aa), xl.Int(bb)] -> xl.int(aa * bb)
                _ -> xl.none()
            }
        })),
    ])
    io.println("xl_dict: " <> xl.json_stringify([xl_dict]))
    io.println("xl_dict: " <> xl.json_stringify([xl_dict, xl.dict([#("pretty", xl.bool(True))])]))
}
