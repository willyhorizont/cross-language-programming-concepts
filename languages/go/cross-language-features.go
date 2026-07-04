package main

import (
	xl "cross-language-programming-concepts/runtimes/go/willyhorizont/runtime"
)

func main() {
	/*
	1. support closure as value, or has workaround
	*/
	sayHello := func(va ...interface{}) interface{} {
		itr := xl.MakeIterator(va)
		callbackFunction := itr.Next()
		xl.Println("hello")
		xl.ToClosure(callbackFunction).Call()
		return nil
	}
	sayHello(func(va ...interface{}) interface{} {
		xl.Println("world")
		return nil
	})
	createMultiplier := func(va ...interface{}) interface{} {
		itr := xl.MakeIterator(va)
		aa := itr.Next()
		return func(va ...interface{}) interface{} {
			itr := xl.MakeIterator(va)
			bb := itr.Next()
			return xl.ToInt(aa) * xl.ToInt(bb)
		}
	}
	multiplyByTwo := createMultiplier(2)
	xl.Println("multiply_by_two(10): ", xl.ToClosure(multiplyByTwo).Call(10))

	/*
	2. support dynamic-typed value, or has workaround
	*/
	xlList := xl.XlList{
		nil,
		true,
		false,
		"foo",
		0,
		-123,
		123.789,
		-123.789,
		xl.XlList{1, 2, 3},
		xl.XlDict{"foo": "bar"},
		func(va ...interface{}) interface{} {
			itr := xl.MakeIterator(va)
			aa := itr.Next()
			bb := itr.Next()
			return xl.ToInt(aa) * xl.ToInt(bb)
		},
	}
	xl.Println(xl.JsonStringify(xlList))
	xl.Println(xl.JsonStringify(xlList, xl.XlDict{"pretty": true}))
	xlDict := xl.XlDict{
		"xl_none": nil,
		"xl_bool_true": true,
		"xl_bool_false": false,
		"xl_string": "foo",
		"xl_int_positive": 0,
		"xl_int_negative": -123,
		"xl_float_positive": 123.789,
		"xl_float_negative": -123.789,
		"xl_list": xl.XlList{1, 2, 3},
		"xl_dict": xl.XlDict{"foo": "bar"},
		"xl_closure": func(va ...interface{}) interface{} {
			itr := xl.MakeIterator(va)
			aa := itr.Next()
			bb := itr.Next()
			return xl.ToInt(aa) * xl.ToInt(bb)
		},
	}
	xl.Println(xl.JsonStringify(xlDict))
	xl.Println(xl.JsonStringify(xlDict, xl.XlDict{"pretty": true}))
}
