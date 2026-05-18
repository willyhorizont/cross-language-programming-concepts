package main

import (
    "fmt"
    "cross-language-programming-concepts/runtimes/go/willyhorizont"
)

func main() {
	sayHello := willyhorizont.TypeJsLikeFunction(func(variadicArguments ...willyhorizont.TypeAny) willyhorizont.TypeAny {
		callbackFunction := variadicArguments[0]
        fmt.Println("hello")
        (callbackFunction.(willyhorizont.TypeJsLikeFunction))()
		return nil
    })
    sayHello(willyhorizont.TypeJsLikeFunction(func(variadicArguments ...willyhorizont.TypeAny) willyhorizont.TypeAny {
		fmt.Println("how are you?")
		return nil
    }))
	var multiply willyhorizont.TypeAny = willyhorizont.TypeJsLikeFunction(func(variadicArguments ...willyhorizont.TypeAny) willyhorizont.TypeAny {
		a := variadicArguments[0]
		return (willyhorizont.TypeJsLikeFunction(func(variadicArguments ...willyhorizont.TypeAny) willyhorizont.TypeAny {
			b := variadicArguments[0]
			return (willyhorizont.Utils.ParseFloat(willyhorizont.Utils.ParseFloat(a).(willyhorizont.TypeJsLikeFloat) * willyhorizont.Utils.ParseFloat(b).(willyhorizont.TypeJsLikeFloat)).(willyhorizont.TypeJsLikeFloat))
		}))
	})
	multiplyByTwo := multiply.(willyhorizont.TypeJsLikeFunction)(2)
	fmt.Println("multiplyByTwo(10):", multiplyByTwo.(willyhorizont.TypeJsLikeFunction)(10))

	somePythonLikeList := willyhorizont.TypePythonLikeList{
		nil,
		true,
		false,
		"foo",
		123,
		-123,
		123.789,
		-123.789,
		willyhorizont.TypePythonLikeList{1, 2, 3},
		willyhorizont.TypePythonLikeDict{"foo": "bar"},
		willyhorizont.TypeJsLikeFunction(func(variadicArguments ...willyhorizont.TypeAny) willyhorizont.TypeAny {
			a, b := variadicArguments[0], variadicArguments[1]
			return (willyhorizont.Utils.ParseFloat(willyhorizont.Utils.ParseFloat(a).(willyhorizont.TypeJsLikeFloat) * willyhorizont.Utils.ParseFloat(b).(willyhorizont.TypeJsLikeFloat)).(willyhorizont.TypeJsLikeFloat))
		}),
	}
	fmt.Println(willyhorizont.Utils.GetIsPythonLikeList(somePythonLikeList))

	somePythonLikeDict := willyhorizont.TypePythonLikeDict{
		"some_null": nil,
		"some_boolean_true": true,
		"some_boolean_false": false,
		"some_string": "foo",
		"some_int_positive": 123,
		"some_int_negative": -123,
		"some_float_positive": 123.789,
		"some_float_negative": -123.789,
		"some_python_like_list": willyhorizont.TypePythonLikeList{1, 2, 3},
		"some_python_like_dict": willyhorizont.TypePythonLikeDict{"foo": "bar"},
		"some_function": willyhorizont.TypeJsLikeFunction(func(variadicArguments ...willyhorizont.TypeAny) willyhorizont.TypeAny {
			a, b := variadicArguments[0], variadicArguments[1]
			return (willyhorizont.Utils.ParseFloat(willyhorizont.Utils.ParseFloat(a).(willyhorizont.TypeJsLikeFloat) * willyhorizont.Utils.ParseFloat(b).(willyhorizont.TypeJsLikeFloat)).(willyhorizont.TypeJsLikeFloat))
		}),
	}
	fmt.Println(willyhorizont.Utils.GetIsPythonLikeDict(somePythonLikeDict))
	fmt.Println(willyhorizont.Utils.GetStringValueOfPrimitive(nil))
	fmt.Println(willyhorizont.Utils.GetStringValueOfPrimitive(true))
	fmt.Println(willyhorizont.Utils.GetStringValueOfPrimitive(false))
	fmt.Println(willyhorizont.Utils.GetStringValueOfPrimitive("foo"))
	fmt.Println(willyhorizont.Utils.GetStringValueOfPrimitive(123))
	fmt.Println(willyhorizont.Utils.GetStringValueOfPrimitive(-123))
	fmt.Println(willyhorizont.Utils.GetStringValueOfPrimitive(123.789))
	fmt.Println(willyhorizont.Utils.GetStringValueOfPrimitive(-123.789))
}