extends SceneTree

const Xl = preload("../../runtimes/gdscript/willyhorizont/runtime/xl.gd")

func main():
	# 1. support closure as value, or has workaround
	var say_hello = func (callback_function):
		print("hello")
		callback_function.call()
	say_hello.call(func ():
		print("world")
	)
	var create_multiplier = func (aa): return func (bb): return (aa * bb)
	var multiply_by_two = create_multiplier.call(2)
	print("multiply_by_two(10): " + str(multiply_by_two.call(10)))
	var multiply_by_eight = create_multiplier.call(8)
	print("multiply_by_eight(4): " + str(multiply_by_eight.call(4)))
	print("multiply_by_two(8): " + str(multiply_by_two.call(8)))

	# 2. support dynamic-typed value, or has workaround
	var xl_list = [
		null,
		true,
		false,
		"foo",
		0,
		-123,
		123.789,
		-123.789,
		[1, 2, 3],
		{"foo": "bar"},
		func (aa, bb): return (aa * bb),
	]
	print("xl_list: " + Xl.json_stringify(xl_list))
	print("xl_list: " + Xl.json_stringify(xl_list, {"pretty": true}))
	var xl_dict = {
		"xl_none": null,
		"xl_bool_true": true,
		"xl_bool_false": false,
		"xl_string": "foo",
		"xl_int_positive": 0,
		"xl_int_negative": -123,
		"xl_float_positive": 123.789,
		"xl_float_negative": -123.789,
		"xl_list": [1, 2, 3],
		"xl_dict": {"foo": "bar"},
		"xl_closure": func (aa, bb): return (aa * bb),
	}
	print("xl_dict: " + Xl.json_stringify(xl_dict))
	print("xl_dict: " + Xl.json_stringify(xl_dict, {"pretty": true}))

func _init():
	main()
	quit()
