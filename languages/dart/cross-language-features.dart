import "../../runtimes/dart/willyhorizont/runtime/xl.dart";

void main() {
    /*
    1. support lambda as value, or has workaround
    */
    var sayHello = (va) {
        var itr = xl.iter(va);
        var callback = xl.next(itr);
        print("hello");
        callback([]);
    };
    sayHello([(va) {
        print("world");
    }]);
    var createMultiplier = (va) {
        var itr = xl.iter(va);
        var aa = xl.next(itr);
        return (va) {
            var itr = xl.iter(va);
            var bb = xl.next(itr);
            return aa * bb;
        };
    };
    var multiplyByTwo = createMultiplier([2]);
    print("multiply_by_two(10): ${multiplyByTwo([10])}");
    var multiplyByEight = createMultiplier([8]);
    print("multiply_by_eight(4): ${multiplyByEight([4])}");
    print("multiply_by_two(8): ${multiplyByTwo([8])}");
    
    /*
    2. support dynamic-typed value, or has workaround
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
            var itr = xl.iter(va);
            var aa = xl.next(itr);
            var bb = xl.next(itr);
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
        "xl_lambda": (va) {
            var itr = xl.iter(va);
            var aa = xl.next(itr);
            var bb = xl.next(itr);
            return aa * bb;
        },
    };
    print("xl_dict: ${xl.jsonStringify(xlDict)}");
    print("xl_dict: ${xl.jsonStringify(xlDict, pretty: true)}");
}
