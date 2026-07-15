import willyhorizont.runtime.Xl

@main def apply(): Unit = {
    /*
    1. support closure as value, or has workaround
    */
    val sayHello = ((va: Seq[Any]) => {
        def body(): Any = {
            val callbackFunction = va(0)
            println("hello")
            callbackFunction.asInstanceOf[Seq[Any] => Any](Seq(null))
            return null
        }
        body()
    }).asInstanceOf[Seq[Any] => Any]
    sayHello.asInstanceOf[Seq[Any] => Any](Seq(((va: Seq[Any]) => {
        def body(): Any = {
            println("world")
            return null
        }
        body()
    }).asInstanceOf[Seq[Any] => Any]))
    val createMultiplier = ((va: Seq[Any]) => {
        def body(): Any = {
            val aa = va(0)
            return ((va: Seq[Any]) => {
                def body(): Any = {
                    val bb = va(0)
                    return aa.asInstanceOf[Int] * bb.asInstanceOf[Int]
                }
                body()
            }).asInstanceOf[Seq[Any] => Any]
        }
        body()
    }).asInstanceOf[Seq[Any] => Any]
    val multiplyByTwo = createMultiplier.asInstanceOf[Seq[Any] => Any](Seq(2))
    println(s"multiply_by_two(10): ${multiplyByTwo.asInstanceOf[Seq[Any] => Any](Seq(10))}")
    val multiplyByEight = createMultiplier.asInstanceOf[Seq[Any] => Any](Seq(8))
    println(s"multiply_by_eight(4): ${multiplyByEight.asInstanceOf[Seq[Any] => Any](Seq(4))}")
    println(s"multiply_by_two(8): ${multiplyByTwo.asInstanceOf[Seq[Any] => Any](Seq(8))}")
    
    /*
    2. support dynamic-typed value, or has workaround
    */
    val xlList = Xl.list(
        null,
        true,
        false,
        "foo",
        0,
        -123,
        123.789,
        -123.789,
        Xl.list(1, 2, 3),
        Xl.dict("foo" -> "bar"),
        ((va: Seq[Any]) => {
            def body(): Any = {
                val aa = va(0)
                val bb = va(1)
                return aa.asInstanceOf[Int] * bb.asInstanceOf[Int]
            }
            body()
        }).asInstanceOf[Seq[Any] => Any]
    )
    println(s"xl_list: ${Xl.jsonStringify(xlList)}")
    println(s"xl_list: ${Xl.jsonStringify(xlList, pretty = true)}")
    val xlDict = Xl.dict(
        "xl_none" -> null,
        "xl_bool_true" -> true,
        "xl_bool_false" -> false,
        "xl_string" -> "foo",
        "xl_int_positive" -> 0,
        "xl_int_negative" -> -123,
        "xl_float_positive" -> 123.789,
        "xl_float_negative" -> -123.789,
        "xl_list" -> Xl.list(1, 2, 3),
        "xl_dict" -> Xl.dict("foo" -> "bar"),
        "xl_closure" -> ((va: Seq[Any]) => {
            def body(): Any = {
                val aa = va(0)
                val bb = va(1)
                return aa.asInstanceOf[Int] * bb.asInstanceOf[Int]
            }
            body()
        }).asInstanceOf[Seq[Any] => Any]
    )
    println(s"xl_dict: ${Xl.jsonStringify(xlDict)}")
    println(s"xl_dict: ${Xl.jsonStringify(xlDict, pretty = true)}")
}
