package main

import (
	XL "cross-language-programming-concepts/runtimes/go/willyhorizont/runtime"
)

func main() {
	/*
	1. support closure as value, or has workaround
	*/
	sayHello := func(va ...interface{}) interface{} {
		itr := XL.Iter(va)
		callbackFunction := itr.Next()
		XL.Println("hello")
		XL.ToClosure(callbackFunction).Call()
		return nil
	}
	sayHello(func(va ...interface{}) interface{} {
		XL.Println("world")
		return nil
	})
	createMultiplier := func(va ...interface{}) interface{} {
		itr := XL.Iter(va)
		aa := itr.Next()
		return func(va ...interface{}) interface{} {
			itr := XL.Iter(va)
			bb := itr.Next()
			return XL.ToInt(aa) * XL.ToInt(bb)
		}
	}
	multiplyByTwo := createMultiplier(2)
	XL.Println("multiply_by_two(10): ", XL.ToClosure(multiplyByTwo).Call(10))
	multiplyByEight := createMultiplier(8)
	XL.Println("multiply_by_eight(4): ", XL.ToClosure(multiplyByEight).Call(4))
	XL.Println("multiply_by_two(8): ", XL.ToClosure(multiplyByTwo).Call(8))

	/*
	2. support dynamic-typed value, or has workaround
	*/
	xlList := XL.List{
		nil,
		true,
		false,
		"foo",
		0,
		-123,
		123.789,
		-123.789,
		XL.List{1, 2, 3},
		XL.Dict{"foo": "bar"},
		func(va ...interface{}) interface{} {
			itr := XL.Iter(va)
			aa := itr.Next()
			bb := itr.Next()
			return XL.ToInt(aa) * XL.ToInt(bb)
		},
	}
	XL.Println(XL.JsonStringify(xlList))
	XL.Println(XL.JsonStringify(xlList, XL.Dict{"pretty": true}))
	xlDict := XL.Dict{
		"xl_none": nil,
		"xl_bool_true": true,
		"xl_bool_false": false,
		"xl_string": "foo",
		"xl_int_positive": 0,
		"xl_int_negative": -123,
		"xl_float_positive": 123.789,
		"xl_float_negative": -123.789,
		"xl_list": XL.List{1, 2, 3},
		"xl_dict": XL.Dict{"foo": "bar"},
		"xl_closure": func(va ...interface{}) interface{} {
			itr := XL.Iter(va)
			aa := itr.Next()
			bb := itr.Next()
			return XL.ToInt(aa) * XL.ToInt(bb)
		},
	}
	XL.Println(XL.JsonStringify(xlDict))
	XL.Println(XL.JsonStringify(xlDict, XL.Dict{"pretty": true}))
}
