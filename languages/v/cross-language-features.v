module main

import willyhorizont.runtime.xl

fn main() {
	/*
	1. support lambda as value, or has workaround
	*/
	say_hello := xl.init(xl.lambda(value: fn (va xl.Type) xl.Type {
		mut itr := xl.iter(va)
		callback_function := xl.next(mut itr)
		println("hello")
		callback_function.call()
		return xl.init()
	}))
	say_hello.call(xl.init(xl.lambda(value: fn (va xl.Type) xl.Type {
		println("world")
		return xl.init()
	})))
	create_multiplier := xl.init(xl.lambda(value: fn (va xl.Type) xl.Type {
		mut itr := xl.iter(va)
		aa := xl.next(mut itr)
		return xl.init(xl.lambda(value: fn [aa] (va xl.Type) xl.Type {
			mut itr := xl.iter(va)
			bb := xl.next(mut itr)
			return xl.init(xl.to_int(aa) * xl.to_int(bb))
		}))
	}))
	multiply_by_two := create_multiplier.call(2)
	println("multiply_by_two(10): ${multiply_by_two.call(10).to_int()}")
	multiply_by_eight := create_multiplier.call(8)
	println("multiply_by_eight(4): ${multiply_by_eight.call(4).to_int()}")
	println("multiply_by_two(8): ${multiply_by_two.call(8).to_int()}")
    
	/*
	2. support dynamic-typed value, or has workaround
	*/
    xl_list := xl.init([
        xl.init(),
        xl.init(true),
        xl.init(false),
        xl.init("foo"),
        xl.init(0),
        xl.init(-123),
        xl.init(123.789),
        xl.init(-123.789),
        xl.init([xl.init(1), xl.init(2), xl.init(3)]),
        xl.init({ "foo": xl.init("bar") }),
        xl.init(xl.lambda(value: fn (va xl.Type) xl.Type {
            mut itr := xl.iter(va)
            aa := xl.next(mut itr)
            bb := xl.next(mut itr)
            return xl.init(xl.to_int(aa) * xl.to_int(bb))
        })),
    ])
    println("xl_list: ${xl.json_stringify(xl_list)}")
    println("xl_list: ${xl.json_stringify(xl_list, pretty: true)}")
    xl_dict := xl.init({
        "xl_none": xl.init(),
        "xl_bool_true": xl.init(true),
        "xl_bool_false": xl.init(false),
        "xl_string": xl.init("foo"),
        "xl_int_positive": xl.init(0),
        "xl_int_negative": xl.init(-123),
        "xl_float_positive": xl.init(123.789),
        "xl_float_negative": xl.init(-123.789),
        "xl_list": xl.init([xl.init(1), xl.init(2), xl.init(3)]),
        "xl_dict": xl.init({ "foo": xl.init("bar") }),
        "xl_lambda": xl.init(xl.lambda(value: fn (va xl.Type) xl.Type {
            mut itr := xl.iter(va)
            aa := xl.next(mut itr)
            bb := xl.next(mut itr)
            return xl.init(xl.to_int(aa) * xl.to_int(bb))
        })),
    })
    println("xl_dict: ${xl.json_stringify(xl_dict)}")
    println("xl_dict: ${xl.json_stringify(xl_dict, pretty: true)}")
}
