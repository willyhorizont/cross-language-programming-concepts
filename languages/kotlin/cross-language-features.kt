import runtimes.kotlin.willyhorizont.runtime.xl

fun main() {
    /*
    1. support closure as value, or has workaround
    */
    val sayHello = object : xl.Closure {
        override fun call(va: Array<out Any?>): Any? {
            val itr = va.iterator()
            val callbackFunction = itr.next() as xl.Closure
            println("hello")
            callbackFunction()
            return null
        }
    }
    sayHello(object : xl.Closure {
        override fun call(va: Array<out Any?>): Any? {
            println("world")
            return null
        }
    })
    val createMultiplier = object : xl.Closure {
        override fun call(va: Array<out Any?>): Any? {
            val itr = va.iterator()
            val aa = itr.next() as Int
            return object : xl.Closure {
                override fun call(va: Array<out Any?>): Any? {
                    val itr = va.iterator()
                    val bb = itr.next() as Int
                    return aa * bb
                }
            }
        }
    }
    val multiplyByTwo = createMultiplier(2) as xl.Closure
    println("multiply_by_two(10): ${multiplyByTwo(10)}")
    val multiplyByEight = createMultiplier(8) as xl.Closure
    println("multiply_by_eight(4): ${multiplyByEight(4)}")
    println("multiply_by_two(8): ${multiplyByTwo(8)}")

    /*
    2. support dynamic-typed value, or has workaround
    */
    val xlList = mutableListOf<Any?>(
        null,
        true,
        false,
        "foo",
        0,
        -123,
        123.789,
        -123.789,
        arrayListOf<Any?>(1, 2, 3),
        hashMapOf<String, Any?>("foo" to "bar"),
        object : xl.Closure {
            override fun call(va: Array<out Any?>): Any? {
                val itr = va.iterator()
                val aa = itr.next() as Int
                val bb = itr.next() as Int
                return aa * bb
            }
        },
    )
    println(xl.jsonStringify(xlList))
    println(xl.jsonStringify(xlList, pretty = true))
    val xlDict = hashMapOf<String, Any?>(
        "xl_none" to null,
        "xl_bool_true" to true,
        "xl_bool_false" to false,
        "xl_string" to "foo",
        "xl_int_positive" to 0,
        "xl_int_negative" to -123,
        "xl_float_positive" to 123.789,
        "xl_float_negative" to -123.789,
        "xl_list" to arrayListOf<Any?>(1, 2, 3),
        "xl_dict" to hashMapOf<String, Any?>("foo" to "bar"),
        "xl_closure" to object : xl.Closure {
            override fun call(va: Array<out Any?>): Any? {
                val itr = va.iterator()
                val aa = itr.next() as Int
                val bb = itr.next() as Int
                return aa * bb
            }
        },
    )
    println(xl.jsonStringify(xlDict))
    println(xl.jsonStringify(xlDict, pretty = true))
}
