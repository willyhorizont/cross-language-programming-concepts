extends SceneTree


func main():
	# 1. support closure as value, or has workaround
	var say_hello = func (callback_function):
		print("hello")
		callback_function.call()
	say_hello.call(func ():
		print("world")
	)
	var multiply = func (a): return func (b): return (a * b)
	var multiply_by_two = multiply.call(2)
	print("multiply_by_two.call(10): " + str(multiply_by_two.call(10)))
	var multiply_by_eight = multiply.call(8)
	print("multiply_by_eight.call(4): " + str(multiply_by_eight.call(4)))
	print("multiply_by_two.call(8): " + str(multiply_by_two.call(8)))

	# 2. support dynamic-typed value, or has workaround
	var some_python_like_list = [
		null,
		true,
		false,
		"foo",
		123,
		-123,
		123.789,
		-123.789,
		[1, 2, 3],
		{"foo": "bar"},
		func (a, b): return (a * b),
	]
	print("some_python_like_list: " + str(some_python_like_list))
	var some_python_like_dict = {
		"some_null": null,
		"some_boolean_true": true,
		"some_boolean_false": false,
		"some_string": "foo",
		"some_int_positive": 123,
		"some_int_negative": -123,
		"some_float_positive": 123.789,
		"some_float_negative": -123.789,
		"some_python_like_list": [1, 2, 3],
		"some_python_like_dict": {"foo": "bar"},
		"some_function": func (a, b): return (a * b),
	}
	print("some_python_like_dict: " + str(some_python_like_dict))


func _init():
	main()
	quit()
