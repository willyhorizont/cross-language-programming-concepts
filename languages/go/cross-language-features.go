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
var checkIsPythonLikeList = willyhorizont.Utils.CheckIsPythonLikeList
var checkIsPythonLikeDict = willyhorizont.Utils.CheckIsPythonLikeDict
var parseFloat = willyhorizont.Utils.ParseFloat
var getType = willyhorizont.Utils.GetType

func main() {
	sayHello := jsLikeFunction(func(variadicArguments ...any) any {
		callbackFunction := any(variadicArguments[0])
        fmt.Println("hello")
        (callbackFunction.(jsLikeFunction))()
		return nil
    })
    sayHello(jsLikeFunction(func(variadicArguments ...any) any {
		fmt.Println("how are you?")
		return nil
    }))
	var multiply any = jsLikeFunction(func(variadicArguments ...any) any {
		a := any(variadicArguments[0])
		return (jsLikeFunction(func(variadicArguments ...any) any {
			b := any(variadicArguments[0])
			return (parseFloat(parseFloat(a).(float64) * parseFloat(b).(float64)).(float64))
		}))
	})
	multiplyByTwo := multiply.(jsLikeFunction)(2)
	fmt.Println("multiplyByTwo(10):", multiplyByTwo.(jsLikeFunction)(10))

	somePythonLikeList := pythonLikeList{
		jsLikeUndefined,
		nil,
		true,
		false,
		"foo",
		123,
		-123,
		123.789,
		-123.789,
		pythonLikeList{1, 2, 3},
		pythonLikeDict{"foo": "bar"},
		jsLikeFunction(func(variadicArguments ...any) any {
			a, b := any(variadicArguments[0]), any(variadicArguments[1])
			return (parseFloat(parseFloat(a).(float64) * parseFloat(b).(float64)).(float64))
		}),
	}
	fmt.Println(checkIsPythonLikeList(somePythonLikeList))

	somePythonLikeDict := pythonLikeDict{
		"some_undefined": jsLikeUndefined,
		"some_null": nil,
		"some_boolean_true": true,
		"some_boolean_false": false,
		"some_string": "foo",
		"some_int_positive": 123,
		"some_int_negative": -123,
		"some_float_positive": 123.789,
		"some_float_negative": -123.789,
		"some_python_like_list": pythonLikeList{1, 2, 3},
		"some_python_like_dict": pythonLikeDict{"foo": "bar"},
		"some_function": jsLikeFunction(func(variadicArguments ...any) any {
			a, b := any(variadicArguments[0]), any(variadicArguments[1])
			return (parseFloat(parseFloat(a).(float64) * parseFloat(b).(float64)).(float64))
		}),
	}
	fmt.Println(checkIsPythonLikeDict(somePythonLikeDict))
}