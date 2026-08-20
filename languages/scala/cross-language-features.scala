import willyhorizont.runtime.Xl

@main def apply(): Unit = {
    /*
    ' -- 1. support lambda as value, or has workaround
    */
    val sayHello = ((va: Any) => {
        def call(): Any = {
            val itr = Xl.iter(va)
            val callback = Xl.next(itr)
            println("hello")
            Xl.call(callback)
            return null
        }
        call()
    })
    Xl.call(sayHello, ((va: Any) => {
        def call(): Any = {
            println("world")
            return null
        }
        call()
    }))
    val createMultiplier = ((va: Any) => {
        def call(): Any = {
            val itr = Xl.iter(va)
            val aa = Xl.next(itr)
            return ((va: Any) => {
                def call(): Any = {
                    val itr = Xl.iter(va)
                    val bb = Xl.next(itr)
                    return aa.asInstanceOf[Int] * bb.asInstanceOf[Int]
                }
                call()
            })
        }
        call()
    })
    val multiplyByTwo = Xl.call(createMultiplier, 2)
    println(s"multiply_by_two(10): ${Xl.call(multiplyByTwo, 10)}")
    val multiplyByEight = Xl.call(createMultiplier, 8)
    println(s"multiply_by_eight(4): ${Xl.call(multiplyByEight, 4)}")
    println(s"multiply_by_two(8): ${Xl.call(multiplyByTwo, 8)}")
    
    /*
    ' -- 2. support dynamic-typed value, or has workaround
    */
    val xlList = Xl.initList(
        null,
        true,
        false,
        "foo",
        0,
        -123,
        123.789,
        -123.789,
        Xl.initList(1, 2, 3),
        Xl.initDict("foo" -> "bar"),
        ((va: Any) => {
            def call(): Any = {
                val itr = Xl.iter(va)
                val aa = Xl.next(itr)
                val bb = Xl.next(itr)
                return aa.asInstanceOf[Int] * bb.asInstanceOf[Int]
            }
            call()
        })
    )
    println(s"xl_list: ${Xl.jsonStringify(xlList)}")
    println(s"xl_list: ${Xl.jsonStringify(xlList, pretty = true)}")
    val xlDict = Xl.initDict(
        "xl_none" -> null,
        "xl_bool_true" -> true,
        "xl_bool_false" -> false,
        "xl_string" -> "foo",
        "xl_int_positive" -> 0,
        "xl_int_negative" -> -123,
        "xl_float_positive" -> 123.789,
        "xl_float_negative" -> -123.789,
        "xl_list" -> Xl.initList(1, 2, 3),
        "xl_dict" -> Xl.initDict("foo" -> "bar"),
        "xl_lambda" -> ((va: Any) => {
            def call(): Any = {
                val itr = Xl.iter(va)
                val aa = Xl.next(itr)
                val bb = Xl.next(itr)
                return aa.asInstanceOf[Int] * bb.asInstanceOf[Int]
            }
            call()
        }),
    )
    println(s"xl_dict: ${Xl.jsonStringify(xlDict)}")
    println(s"xl_dict: ${Xl.jsonStringify(xlDict, pretty = true)}")
}
