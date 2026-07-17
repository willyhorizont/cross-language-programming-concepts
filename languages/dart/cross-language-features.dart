import '../../runtimes/willyhorizont/runtime/xl.dart' as xl;

void main() {
	/*
	1. support closure as value, or has workaround
	*/
	var sayHello = (va) {
		var itr = va.iterator;
		var callbackFunction = (itr..moveNext()).current;
		print("hello");
		callbackFunction([]);
	};
	sayHello([(va) {
		print("world");
	}]);
	var createMultiplier = (va) {
		var itr = va.iterator;
		var aa = (itr..moveNext()).current;
		return (va) {
			var itr = va.iterator;
			var bb = (itr..moveNext()).current;
			return aa * bb;
		};
	};
	var multiplyByTwo = createMultiplier([2]);
	print("multiply_by_two(10): ${multiplyByTwo([10])}");
	var multiplyByEight = createMultiplier([8]);
	print("multiply_by_eight(4): ${multiplyByEight([4])}");
	print("multiply_by_two(8): ${multiplyByTwo([8])}");
    
	/*
	2. support var-typed value, or has workaround
	*/
	var xlList = [
		null,
		true,
		false,
		"foo",
		0,
		-123,
		123.789,
		-123.789,
		[1, 2, 3],
		{ "foo": "bar" },
		(va) {
			var itr = va.iterator;
			var aa = (itr..moveNext()).current;
			var bb = (itr..moveNext()).current;
			return aa * bb;
		},
	];
	print("xl_list: ${xl.jsonStringify(xlList)}");
	print("xl_list: ${xl.jsonStringify(xlList, pretty: true)}");
	var xlDict = {
		"xl_none": null,
		"xl_bool_true": true,
		"xl_bool_false": false,
		"xl_string": "foo",
		"xl_int_positive": 0,
		"xl_int_negative": -123,
		"xl_float_positive": 123.789,
		"xl_float_negative": -123.789,
		"xl_list": [1, 2, 3],
		"xl_dict": { "foo": "bar" },
		"xl_closure": (va) {
			var itr = va.iterator;
			var aa = (itr..moveNext()).current;
			var bb = (itr..moveNext()).current;
			return aa * bb;
		},
	};
	print("xl_dict: ${xl.jsonStringify(xlDict)}");
	print("xl_dict: ${xl.jsonStringify(xlDict, pretty: true)}");
}
