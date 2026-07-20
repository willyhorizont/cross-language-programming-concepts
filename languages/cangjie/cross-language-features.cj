import willyhorizont.runtime as xl

main() {
    /*
    1. support closure as value, or has workaround
    */
    let sayHello: Any = { va: xl.Vararg =>
        let itr = xl.iter(va)
        match (xl.next(itr)) {
            case callbackFunction: xl.Closure =>
                println("hello")
                callbackFunction([xl.NONE])
                return xl.NONE
            case _ =>
                throw Exception("Error: Invalid arguments.")
        }
    }
    xl.call(sayHello, [{ _: xl.Vararg =>
        println("world")
        return xl.NONE
    }])
    let createMultiplier: Any = { va: xl.Vararg =>
        let itr = xl.iter(va)
        match (xl.next(itr)) {
            case aa: xl.Int =>
                return { va: xl.Vararg =>
                    let itr = xl.iter(va)
                    (match (xl.next(itr)) {
                        case bb: xl.Int =>
                            return aa * bb
                        case _ =>
                            throw Exception("Error: Invalid arguments.")
                    }) as Any
                }
            case _ =>
                throw Exception("Error: Invalid arguments.")
        }
    }
    let multiplyByTwo: Any = xl.call(createMultiplier, [2])
    println("multiply_by_two(10): ${xl.jsonStringify(xl.call(multiplyByTwo, [10]))}")
    let multiplyByEight: Any = xl.call(createMultiplier, [8])
    println("multiply_by_eight(4): ${xl.jsonStringify(xl.call(multiplyByEight, [4]))}")
    println("multiply_by_two(8): ${xl.jsonStringify(xl.call(multiplyByTwo, [8]))}")

    /*
    2. support dynamic-typed value, or has workaround
    */
    let xlList: Any = xl.List([
        xl.NONE,
        true,
        false,
        "foo",
        0,
        -123,
        123.789,
        -123.789,
        xl.List([1, 2, 3]),
        xl.Dict([("foo", "bar")]),
        { va: xl.Vararg =>
            let itr = xl.iter(va)
            (match ((
                xl.next(itr),
                xl.next(itr),
            )) {
                case (aa: xl.Int, bb: xl.Int) =>
                    return aa * bb
                case _ =>
                    throw Exception("Error: Invalid arguments.")
            }) as Any
        },
    ])
    println("xl_list: ${xl.jsonStringify(xlList)}")
    println("xl_list: ${xl.jsonStringify(xlList, pretty: true)}")
    let xlDict: Any = xl.Dict([
        ("xl_none", xl.NONE),
        ("xl_bool_true", true),
        ("xl_bool_false", false),
        ("xl_string", "foo"),
        ("xl_int_positive", 0),
        ("xl_int_negative", -123),
        ("xl_float_positive", 123.789),
        ("xl_float_negative", -123.789),
        ("xl_list", xl.List([1, 2, 3])),
        ("xl_dict", xl.Dict([("foo", "bar")])),
        ("xl_closure", { va: xl.Vararg =>
            let itr = xl.iter(va)
            (match ((
                xl.next(itr),
                xl.next(itr),
            )) {
                case (aa: xl.Int, bb: xl.Int) =>
                    return aa * bb
                case _ =>
                    throw Exception("Error: Invalid arguments.")
            }) as Any
        }),
    ])
    println("xl_dict: ${xl.jsonStringify(xlDict)}")
    println("xl_dict: ${xl.jsonStringify(xlDict, pretty: true)}")
}
