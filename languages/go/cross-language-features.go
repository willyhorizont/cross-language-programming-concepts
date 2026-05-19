package main

import (
    "fmt"
    "cross-language-programming-concepts/runtimes/go/willyhorizont"
)

func main() {
	sayHello := willyhorizont.TypeDotJsLikeFunction(func(variadicArguments ...willyhorizont.TypeDotAny) willyhorizont.TypeDotAny {
		callbackFunction := variadicArguments[0]
        fmt.Println("hello")
        (callbackFunction.(willyhorizont.TypeDotJsLikeFunction))()
		return nil
    })
    sayHello(willyhorizont.TypeDotJsLikeFunction(func(variadicArguments ...willyhorizont.TypeDotAny) willyhorizont.TypeDotAny {
		fmt.Println("how are you?")
		return nil
    }))
	var multiply willyhorizont.TypeDotAny = willyhorizont.TypeDotJsLikeFunction(func(variadicArguments ...willyhorizont.TypeDotAny) willyhorizont.TypeDotAny {
		a := variadicArguments[0]
		return (willyhorizont.TypeDotJsLikeFunction(func(variadicArguments ...willyhorizont.TypeDotAny) willyhorizont.TypeDotAny {
			b := variadicArguments[0]
			return (willyhorizont.Utils.ParseFloat(willyhorizont.Utils.ParseFloat(a).(willyhorizont.TypeDotJsLikeFloat) * willyhorizont.Utils.ParseFloat(b).(willyhorizont.TypeDotJsLikeFloat)).(willyhorizont.TypeDotJsLikeFloat))
		}))
	})
	multiplyByTwo := multiply.(willyhorizont.TypeDotJsLikeFunction)(2)
	fmt.Println("multiplyByTwo(10):", multiplyByTwo.(willyhorizont.TypeDotJsLikeFunction)(10))

	somePythonLikeList := willyhorizont.TypeDotPythonLikeList{
		nil,
		true,
		false,
		"foo",
		123,
		-123,
		123.789,
		-123.789,
		willyhorizont.TypeDotPythonLikeList{1, 2, 3},
		willyhorizont.TypeDotPythonLikeDict{"foo": "bar"},
		willyhorizont.TypeDotJsLikeFunction(func(variadicArguments ...willyhorizont.TypeDotAny) willyhorizont.TypeDotAny {
			a, b := variadicArguments[0], variadicArguments[1]
			return (willyhorizont.Utils.ParseFloat(willyhorizont.Utils.ParseFloat(a).(willyhorizont.TypeDotJsLikeFloat) * willyhorizont.Utils.ParseFloat(b).(willyhorizont.TypeDotJsLikeFloat)).(willyhorizont.TypeDotJsLikeFloat))
		}),
	}
	fmt.Println("somePythonLikeList:", willyhorizont.Utils.JsonStringify(somePythonLikeList, willyhorizont.TypeDotPythonLikeDict{"pretty": true}))

	somePythonLikeDict := willyhorizont.TypeDotPythonLikeDict{
		"some_null": nil,
		"some_boolean_true": true,
		"some_boolean_false": false,
		"some_string": "foo",
		"some_int_positive": 123,
		"some_int_negative": -123,
		"some_float_positive": 123.789,
		"some_float_negative": -123.789,
		"some_python_like_list": willyhorizont.TypeDotPythonLikeList{1, 2, 3},
		"some_python_like_dict": willyhorizont.TypeDotPythonLikeDict{"foo": "bar"},
		"some_function": willyhorizont.TypeDotJsLikeFunction(func(variadicArguments ...willyhorizont.TypeDotAny) willyhorizont.TypeDotAny {
			a, b := variadicArguments[0], variadicArguments[1]
			return (willyhorizont.Utils.ParseFloat(willyhorizont.Utils.ParseFloat(a).(willyhorizont.TypeDotJsLikeFloat) * willyhorizont.Utils.ParseFloat(b).(willyhorizont.TypeDotJsLikeFloat)).(willyhorizont.TypeDotJsLikeFloat))
		}),
	}
	fmt.Println("somePythonLikeDict:", willyhorizont.Utils.JsonStringify(somePythonLikeDict, willyhorizont.TypeDotPythonLikeDict{"pretty": true}))
}