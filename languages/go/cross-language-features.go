package main

import (
    "fmt"
    "cross-language-programming-concepts/runtimes/go/willyhorizont"
)

func main() {
	sayHello := willyhorizont.DataTypeJsLikeFunction(func(variadicArguments ...willyhorizont.DataTypeAny) willyhorizont.DataTypeAny {
		callbackFunction := variadicArguments[0]
        fmt.Println("hello")
        (callbackFunction.(willyhorizont.DataTypeJsLikeFunction))()
		return nil
    })
    sayHello(willyhorizont.DataTypeJsLikeFunction(func(variadicArguments ...willyhorizont.DataTypeAny) willyhorizont.DataTypeAny {
		fmt.Println("wold")
		return nil
    }))
	var multiply willyhorizont.DataTypeAny = willyhorizont.DataTypeJsLikeFunction(func(variadicArguments ...willyhorizont.DataTypeAny) willyhorizont.DataTypeAny {
		a := variadicArguments[0]
		return (willyhorizont.DataTypeJsLikeFunction(func(variadicArguments ...willyhorizont.DataTypeAny) willyhorizont.DataTypeAny {
			b := variadicArguments[0]
			return (willyhorizont.Utils.ParseFloat(willyhorizont.Utils.ParseFloat(a).(willyhorizont.DataTypeJsLikeFloat) * willyhorizont.Utils.ParseFloat(b).(willyhorizont.DataTypeJsLikeFloat)).(willyhorizont.DataTypeJsLikeFloat))
		}))
	})
	multiplyByTwo := multiply.(willyhorizont.DataTypeJsLikeFunction)(2)
	fmt.Println("multiplyByTwo(10):", multiplyByTwo.(willyhorizont.DataTypeJsLikeFunction)(10))

	somePythonLikeList := willyhorizont.DataTypePythonLikeList{
		nil,
		true,
		false,
		"foo",
		123,
		-123,
		123.789,
		-123.789,
		willyhorizont.DataTypePythonLikeList{1, 2, 3},
		willyhorizont.DataTypePythonLikeDict{"foo": "bar"},
		willyhorizont.DataTypeJsLikeFunction(func(variadicArguments ...willyhorizont.DataTypeAny) willyhorizont.DataTypeAny {
			a, b := variadicArguments[0], variadicArguments[1]
			return (willyhorizont.Utils.ParseFloat(willyhorizont.Utils.ParseFloat(a).(willyhorizont.DataTypeJsLikeFloat) * willyhorizont.Utils.ParseFloat(b).(willyhorizont.DataTypeJsLikeFloat)).(willyhorizont.DataTypeJsLikeFloat))
		}),
	}
	fmt.Println("somePythonLikeList:", willyhorizont.Utils.JsonStringify(somePythonLikeList, willyhorizont.DataTypePythonLikeDict{"pretty": true}))

	somePythonLikeDict := willyhorizont.DataTypePythonLikeDict{
		"some_null": nil,
		"some_boolean_true": true,
		"some_boolean_false": false,
		"some_string": "foo",
		"some_int_positive": 123,
		"some_int_negative": -123,
		"some_float_positive": 123.789,
		"some_float_negative": -123.789,
		"some_python_like_list": willyhorizont.DataTypePythonLikeList{1, 2, 3},
		"some_python_like_dict": willyhorizont.DataTypePythonLikeDict{"foo": "bar"},
		"some_function": willyhorizont.DataTypeJsLikeFunction(func(variadicArguments ...willyhorizont.DataTypeAny) willyhorizont.DataTypeAny {
			a, b := variadicArguments[0], variadicArguments[1]
			return (willyhorizont.Utils.ParseFloat(willyhorizont.Utils.ParseFloat(a).(willyhorizont.DataTypeJsLikeFloat) * willyhorizont.Utils.ParseFloat(b).(willyhorizont.DataTypeJsLikeFloat)).(willyhorizont.DataTypeJsLikeFloat))
		}),
	}
	fmt.Println("somePythonLikeDict:", willyhorizont.Utils.JsonStringify(somePythonLikeDict, willyhorizont.DataTypePythonLikeDict{"pretty": true}))
}