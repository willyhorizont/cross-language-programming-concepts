package main

import (
    "fmt"
    "cross-language-programming-concepts/runtimes/go/willyhorizont"
)

type JsLikeAny = willyhorizont.JsLikeAny
type JsLikeArray = willyhorizont.JsLikeArray
type JsLikeObject = willyhorizont.JsLikeObject
type JsLikeFunction = willyhorizont.JsLikeFunction

func main() {
	fmt.Println(willyhorizont.Utils.CheckIsLikeJsNull(nil))

	JsLikeUndefined := willyhorizont.JsLikeUndefined
	checkIsLikeJsNull := willyhorizont.Utils.CheckIsLikeJsNull
	checkIsLikeJsUndefined := willyhorizont.Utils.CheckIsLikeJsUndefined
	arraySome := willyhorizont.Utils.ArraySome
	parseFloat := willyhorizont.Utils.ParseFloat

    fmt.Println(checkIsLikeJsNull(nil))
    // fmt.Println(Utils.CheckIsLikeJsNull(nil)) // this should not work

    something := JsLikeAny(JsLikeUndefined)
    fmt.Println(something)
    fmt.Println(checkIsLikeJsUndefined(something))
    something = nil
    fmt.Println(something)
    something = true
    fmt.Println(something)
    something = false
    fmt.Println(something)
    something = "foo"
    fmt.Println(something)
    something = 123
    fmt.Println(something)
    something = 123.789
    fmt.Println(something)
    something = -123
    fmt.Println(something)
    something = -123.789
    fmt.Println(something)
    something = JsLikeArray{1, 2, 3}
    fmt.Println(something)
    something = JsLikeObject{"foo": "bar"}
    fmt.Println(something)
    something = (func(variadicArguments ...JsLikeAny) JsLikeAny {
		a, b := JsLikeAny(variadicArguments[0]), JsLikeAny(variadicArguments[1])
		return parseFloat(parseFloat(a).(float64) * parseFloat(b).(float64)).(float64)
	})
    fmt.Println(something)

	numbers := JsLikeAny(JsLikeArray{12, 34, 27, 23, 65, 93, 36, 87, 4, 254})

	func() {
		isAnyNumberLessThan500 := JsLikeAny(arraySome(func(variadicArguments ...JsLikeAny) bool {
			anyNumber, _ := JsLikeAny(variadicArguments[0]), JsLikeAny(variadicArguments[1:])
			return (int(parseFloat(anyNumber).(float64)) < 500)
		}, numbers))
		fmt.Println("is any number < 500:", isAnyNumberLessThan500)
		// is any number < 500: true
	
		isAnyNumberMoreThan500 := JsLikeAny(arraySome(func(variadicArguments ...JsLikeAny) bool {
			anyNumber, _ := JsLikeAny(variadicArguments[0]), JsLikeAny(variadicArguments[1:])
			return (int(parseFloat(anyNumber).(float64)) > 500)
		}, numbers))
		fmt.Println("is any number > 500:", isAnyNumberMoreThan500)
		// is any number > 500: false
    }()
}