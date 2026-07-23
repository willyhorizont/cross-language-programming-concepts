package main

import (
	xl "cross-language-programming-concepts/runtimes/go/willyhorizont/runtime"
)

func main() {
	/*
	1. support lambda as value, or has workaround
	*/
	sayHello := func(va ...interface{}) interface{} {
		itr := xl.Iter(va)
		callbackFunction := itr.Next()
		xl.Println("hello")
		xl.ToLambda(callbackFunction).Call()
		return nil
	}
	sayHello(func(va ...interface{}) interface{} {
		xl.Println("world")
		return nil
	})
	createMultiplier := func(va ...interface{}) interface{} {
		itr := xl.Iter(va)
		aa := itr.Next()
		return func(va ...interface{}) interface{} {
			itr := xl.Iter(va)
			bb := itr.Next()
			return xl.ToInt(aa) * xl.ToInt(bb)
		}
	}
	multiplyByTwo := createMultiplier(2)
	xl.Println("multiply_by_two(10): ", xl.ToLambda(multiplyByTwo).Call(10))
	multiplyByEight := createMultiplier(8)
	xl.Println("multiply_by_eight(4): ", xl.ToLambda(multiplyByEight).Call(4))
	xl.Println("multiply_by_two(8): ", xl.ToLambda(multiplyByTwo).Call(8))

	/*
	2. support dynamic-typed value, or has workaround
	*/
	xlList := xl.List{
		nil,
		true,
		false,
		"foo",
		0,
		-123,
		123.789,
		-123.789,
		xl.List{1, 2, 3},
		xl.Dict{"foo": "bar"},
		func(va ...interface{}) interface{} {
			itr := xl.Iter(va)
			aa := itr.Next()
			bb := itr.Next()
			return xl.ToInt(aa) * xl.ToInt(bb)
		},
	}
	xl.Println("xl_list: ", xl.JsonStringify(xlList))
	xl.Println("xl_list: ", xl.JsonStringify(xlList, xl.Dict{"pretty": true}))
	xlDict := xl.Dict{
		"xl_none": nil,
		"xl_bool_true": true,
		"xl_bool_false": false,
		"xl_string": "foo",
		"xl_int_positive": 0,
		"xl_int_negative": -123,
		"xl_float_positive": 123.789,
		"xl_float_negative": -123.789,
		"xl_list": xl.List{1, 2, 3},
		"xl_dict": xl.Dict{"foo": "bar"},
		"xl_lambda": func(va ...interface{}) interface{} {
			itr := xl.Iter(va)
			aa := itr.Next()
			bb := itr.Next()
			return xl.ToInt(aa) * xl.ToInt(bb)
		},
	}
	xl.Println("xl_dict: ", xl.JsonStringify(xlDict))
	xl.Println("xl_dict: ", xl.JsonStringify(xlDict, xl.Dict{"pretty": true}))
}
