import runtimes.kotlin.willyhorizont.runtime.xl

fun main() {
    /*
    1. support lambda as value, or has workaround
    */
    val sayHello: Any? = fun(va: Any?): Any? {
        val itr: Any? = xl.iter(va)
        val callback: Any? = xl.next(itr)
        println("hello")
        xl.call(callback)
        return null
    }
    xl.call(sayHello, fun(va: Any?): Any? {
        println("world")
        return null
    })
    val createMultiplier: Any? = fun(va: Any?): Any? {
        val itr: Any? = xl.iter(va)
        val aa: Any? = xl.next(itr)
        return fun(va: Any?): Any? {
            val itr: Any? = xl.iter(va)
            val bb: Any? = xl.next(itr)
            return xl.toInt(aa) * xl.toInt(bb)
        }
    }
    val multiplyByTwo: Any? = xl.call(createMultiplier, 2)
    println("multiply_by_two(10): ${xl.call(multiplyByTwo, 10)}")
    val multiplyByEight: Any? = xl.call(createMultiplier, 8)
    println("multiply_by_eight(4): ${xl.call(multiplyByEight, 4)}")
    println("multiply_by_two(8): ${xl.call(multiplyByTwo, 8)}")

    /*
    2. support dynamic-typed value, or has workaround
    */
    val xlList: Any? = xl.initList(
        null,
        true,
        false,
        "foo",
        0,
        -123,
        123.789,
        -123.789,
        xl.initList(1, 2, 3),
        xl.initDict("foo" to "bar"),
        fun(va: Any?): Any? {
            val itr: Any? = xl.iter(va)
            val aa: Any? = xl.next(itr)
            val bb: Any? = xl.next(itr)
            return xl.toInt(aa) * xl.toInt(bb)
        },
    )
    println(xl.jsonStringify(xlList))
    println(xl.jsonStringify(xlList, pretty = true))
    val xlDict: Any? = xl.initDict(
        "xl_none" to null,
        "xl_bool_true" to true,
        "xl_bool_false" to false,
        "xl_string" to "foo",
        "xl_int_positive" to 0,
        "xl_int_negative" to -123,
        "xl_float_positive" to 123.789,
        "xl_float_negative" to -123.789,
        "xl_list" to xl.initList(1, 2, 3),
        "xl_dict" to xl.initDict("foo" to "bar"),
        "xl_lambda" to fun(va: Any?): Any? {
            val itr: Any? = xl.iter(va)
            val aa: Any? = xl.next(itr)
            val bb: Any? = xl.next(itr)
            return xl.toInt(aa) * xl.toInt(bb)
        },
    )
    println(xl.jsonStringify(xlDict))
    println(xl.jsonStringify(xlDict, pretty = true))
}
