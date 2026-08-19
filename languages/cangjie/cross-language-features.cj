import willyhorizont.runtime.Xl

main() {
    /*
    1. support lambda as value, or has workaround
    */
    let sayHello: Any = { va: Xl.Vararg =>
        let itr = Xl.iter(va)
        match (Xl.next(itr)) {
            case callback: Xl.Lambda =>
                println("hello")
                callback([Xl.NONE])
                return Xl.NONE
            case _ =>
                throw Exception("Error: Invalid arguments.")
        }
    }
    Xl.call(sayHello, [{ _: Xl.Vararg =>
        println("world")
        return Xl.NONE
    }])
    let createMultiplier: Any = { va: Xl.Vararg =>
        let itr = Xl.iter(va)
        match (Xl.next(itr)) {
            case aa: Xl.Int =>
                return { va: Xl.Vararg =>
                    let itr = Xl.iter(va)
                    (match (Xl.next(itr)) {
                        case bb: Xl.Int =>
                            return aa * bb
                        case _ =>
                            throw Exception("Error: Invalid arguments.")
                    }) as Any
                }
            case _ =>
                throw Exception("Error: Invalid arguments.")
        }
    }
    let multiplyByTwo: Any = Xl.call(createMultiplier, [2])
    println("multiply_by_two(10): ${Xl.jsonStringify(Xl.call(multiplyByTwo, [10]))}")
    let multiplyByEight: Any = Xl.call(createMultiplier, [8])
    println("multiply_by_eight(4): ${Xl.jsonStringify(Xl.call(multiplyByEight, [4]))}")
    println("multiply_by_two(8): ${Xl.jsonStringify(Xl.call(multiplyByTwo, [8]))}")

    /*
    2. support dynamic-typed value, or has workaround
    */
    let xlList: Any = Xl.List([
        Xl.NONE,
        true,
        false,
        "foo",
        0,
        -123,
        123.789,
        -123.789,
        Xl.List([1, 2, 3]),
        Xl.Dict([("foo", "bar")]),
        { va: Xl.Vararg =>
            let itr = Xl.iter(va)
            (match ((
                Xl.next(itr),
                Xl.next(itr),
            )) {
                case (aa: Xl.Int, bb: Xl.Int) =>
                    return aa * bb
                case _ =>
                    throw Exception("Error: Invalid arguments.")
            }) as Any
        },
    ])
    println("xl_list: ${Xl.jsonStringify(xlList)}")
    println("xl_list: ${Xl.jsonStringify(xlList, pretty: true)}")
    let xlDict: Any = Xl.Dict([
        ("xl_none", Xl.NONE),
        ("xl_bool_true", true),
        ("xl_bool_false", false),
        ("xl_string", "foo"),
        ("xl_int_positive", 0),
        ("xl_int_negative", -123),
        ("xl_float_positive", 123.789),
        ("xl_float_negative", -123.789),
        ("xl_list", Xl.List([1, 2, 3])),
        ("xl_dict", Xl.Dict([("foo", "bar")])),
        ("xl_lambda", { va: Xl.Vararg =>
            let itr = Xl.iter(va)
            (match ((
                Xl.next(itr),
                Xl.next(itr),
            )) {
                case (aa: Xl.Int, bb: Xl.Int) =>
                    return aa * bb
                case _ =>
                    throw Exception("Error: Invalid arguments.")
            }) as Any
        }),
    ])
    println("xl_dict: ${Xl.jsonStringify(xlDict)}")
    println("xl_dict: ${Xl.jsonStringify(xlDict, pretty: true)}")
}
