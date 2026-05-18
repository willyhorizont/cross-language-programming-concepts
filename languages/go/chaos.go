package main

import (
    "fmt"
    "cross-language-programming-concepts/runtimes/go/willyhorizont"
    "cross-language-programming-concepts/runtimes/go/willyhorizont/types"
    "cross-language-programming-concepts/runtimes/go/willyhorizont/value"
)

type any = types.Any
type pythonLikeList = types.PythonLikeList
type pythonLikeDict = types.PythonLikeDict
type jsLikeFunction = types.JsLikeFunction

var jsLikeUndefined = value.JsLikeUndefined

func main() {
	fmt.Println(willyhorizont.Utils.CheckIsJsLikeNull(nil))

	checkIsJsLikeNull := willyhorizont.Utils.CheckIsJsLikeNull
	checkIsJsLikeUndefined := willyhorizont.Utils.CheckIsJsLikeUndefined
	arraySome := willyhorizont.Utils.ArraySome
	parseFloat := willyhorizont.Utils.ParseFloat

    fmt.Println(checkIsJsLikeNull(nil))
    // fmt.Println(Utils.CheckIsJsLikeNull(nil)) // this should not work

    var something any = jsLikeUndefined
    fmt.Println(something)
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
    something = pythonLikeList{1, 2, 3}
    fmt.Println(something)
    something = pythonLikeDict{"foo": "bar"}
    fmt.Println(something)
    something = jsLikeFunction(func(variadicArguments ...any) any {
		a, b := any(variadicArguments[0]), any(variadicArguments[1])
		return parseFloat(parseFloat(a).(float64) * parseFloat(b).(float64)).(float64)
	})
    fmt.Println(something)

	numbers := any(pythonLikeList{12, 34, 27, 23, 65, 93, 36, 87, 4, 254})

	func() {
		isAnyNumberLessThan500 := any(arraySome(func(variadicArguments ...any) bool {
			anyNumber, _ := any(variadicArguments[0]), any(variadicArguments[1:])
			return (int(parseFloat(anyNumber).(float64)) < 500)
		}, numbers))
		fmt.Println("is any number < 500:", isAnyNumberLessThan500)
		// is any number < 500: true
	
		isAnyNumberMoreThan500 := any(arraySome(func(variadicArguments ...any) bool {
			anyNumber, _ := any(variadicArguments[0]), any(variadicArguments[1:])
			return (int(parseFloat(anyNumber).(float64)) > 500)
		}, numbers))
		fmt.Println("is any number > 500:", isAnyNumberMoreThan500)
		// is any number > 500: false
    }()

	fmt.Println("asd:")
	fmt.Println(jsLikeUndefined)
	fmt.Println(struct{}{})
	fmt.Println("zxc:")
	fmt.Println(checkIsJsLikeUndefined(jsLikeUndefined))
	fmt.Println(checkIsJsLikeUndefined(struct{}{}))
}