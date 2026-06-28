package {
    import flash.display.Sprite;
    import runtime.willyhorizont.Runtime;

    public class Program extends Sprite {
        public static function run():void {
            /*
            1. support closure as value
            */
            var sayHello:* = function(callbackFunction:*):* {
                Runtime.print("hello");
                callbackFunction();
            };
            sayHello(function():* {
                Runtime.print("world");
            });
            var createMultiplier:* = function(aa:*):* {
                return function(bb:*):* {
                    return aa * bb;
                };
            };
            var multiplyByTwo:* = createMultiplier(2);
            Runtime.print("multiply_by_two(10): " + String(multiplyByTwo(10)));
            var multiplyByEight:* = createMultiplier(8);
            Runtime.print("multiply_by_eight(4): " + String(multiplyByEight(4)));
            Runtime.print("multiply_by_two(8): " + String(multiplyByTwo(8)));

            /*
            2. support dynamic-typed value, or has workaround
            */
            var xlList:* = [
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
                function(aa:*, bb:*):* {
                    return aa * bb;
                }
            ];
            Runtime.print("xl_list: " + Runtime.jsonStringify(xlList));
            Runtime.print("xl_list: " + Runtime.jsonStringify(xlList, { "pretty": true }));
            var xlDict:* = {
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
                "xl_closure": function(aa:*, bb:*):* {
                    return aa * bb;
                }
            };
            Runtime.print("xl_dict: " + Runtime.jsonStringify(xlDict));
            Runtime.print("xl_dict: " + Runtime.jsonStringify(xlDict, { "pretty": true }));
        }
    }
}
