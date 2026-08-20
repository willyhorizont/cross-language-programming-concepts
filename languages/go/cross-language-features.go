package main

import (
    "cross-language-programming-concepts/runtimes/go/willyhorizont/runtime/xl"
)

func main() {
    /*
    1. support lambda as value, or has workaround
    */
    sayHello := xl.InitLambda(func(va xl.Type) xl.Type {
        itr := va.Iter()
        callback := itr.Next()
        xl.Println("hello")
        callback.Call()
        return xl.NONE
    })
    sayHello.Call(xl.InitLambda(func(va xl.Type) xl.Type {
        xl.Println("world")
        return xl.NONE
    }))
    createMultiplier := xl.InitLambda(func(va xl.Type) xl.Type {
        itr := va.Iter()
        aa := itr.Next()
        return xl.InitLambda(func(va xl.Type) xl.Type {
            itr := va.Iter()
            bb := itr.Next()
            return xl.InitInt(aa.ToInt() * bb.ToInt())
        })
    })
    multiplyByTwo := createMultiplier.Call(xl.InitInt(2))
    xl.Println("multiply_by_two(10): ", multiplyByTwo.Call(xl.InitInt(10)))
    multiplyByEight := createMultiplier.Call(xl.InitInt(8))
    xl.Println("multiply_by_eight(4): ", multiplyByEight.Call(xl.InitInt(4)))
    xl.Println("multiply_by_two(8): ", multiplyByTwo.Call(xl.InitInt(8)))

    /*
    2. support dynamic-typed value, or has workaround
    */
    xlList := xl.InitList(
        xl.NONE,
        xl.TRUE,
        xl.FALSE,
        xl.InitString("foo"),
        xl.InitInt(0),
        xl.InitInt(-123),
        xl.InitFloat(123.789),
        xl.InitFloat(-123.789),
        xl.InitList(xl.InitInt(1), xl.InitInt(2), xl.InitInt(3)),
        xl.InitDict(xl.InitPair("foo", xl.InitString("bar"))),
        xl.InitLambda(func(va xl.Type) xl.Type {
            itr := va.Iter()
            aa := itr.Next()
            bb := itr.Next()
            return xl.InitInt(aa.ToInt() * bb.ToInt())
        }),
    )
    xl.Println("xl_list: ", xl.JsonStringify(xlList))
    xl.Println("xl_list: ", xl.JsonStringify(xlList, xl.InitDict(xl.InitPair("pretty", xl.TRUE)))) 
    xlDict := xl.InitDict(
        xl.InitPair("xl_none", xl.NONE),
        xl.InitPair("xl_bool_true", xl.TRUE),
        xl.InitPair("xl_bool_false", xl.FALSE),
        xl.InitPair("xl_string", xl.InitString("foo")),
        xl.InitPair("xl_int_positive", xl.InitInt(0)),
        xl.InitPair("xl_int_negative", xl.InitInt(-123)),
        xl.InitPair("xl_float_positive", xl.InitFloat(123.789)),
        xl.InitPair("xl_float_negative", xl.InitFloat(-123.789)),
        xl.InitPair("xl_list", xl.InitList(xl.InitInt(1), xl.InitInt(2), xl.InitInt(3))),
        xl.InitPair("xl_dict", xl.InitDict(xl.InitPair("foo", xl.InitString("bar")))),
        xl.InitPair("xl_lambda", xl.InitLambda(func(va xl.Type) xl.Type {
            itr := va.Iter()
            aa := itr.Next()
            bb := itr.Next()
            return xl.InitInt(aa.ToInt() * bb.ToInt())
        })),
    )
    xl.Println("xl_dict: ", xl.JsonStringify(xlDict))
    xl.Println("xl_dict: ", xl.JsonStringify(xlDict, xl.InitDict(xl.InitPair("pretty", xl.TRUE))))
}
