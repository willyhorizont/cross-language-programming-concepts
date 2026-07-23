import Foundation
typealias xl = WillyHorizont.Runtime.Xl

@main
struct App {
    static func main() {
        /*
        1. support lambda as value, or has workaround
        */
        let sayHello = { (va: [Any?]) -> Any? in
            var itr = va.makeIterator()
            let callbackFunction = itr.next()!! as! ([Any?]) -> Any?
            print("hello")
            _ = callbackFunction([])
            return nil as Any?
        }
        _ = sayHello([{ (va: [Any?]) -> Any? in
            print("world")
            return nil as Any?
        }])
        let createMultiplier = { (va: [Any?]) -> Any? in
            var itr = va.makeIterator()
            let aa = itr.next()!! as! Int
            return { (va: [Any?]) -> Any? in
                var itr = va.makeIterator()
                let bb = itr.next()!! as! Int
                return aa * bb as Any?
            }
        }
        let multiplyByTwo = createMultiplier([2])
        print("multiply_by_two(10): \((multiplyByTwo! as! ([Any?]) -> Any?)([10]) as! Int)")
        let multiplyByEight = createMultiplier([8])
        print("multiply_by_eight(4): \((multiplyByEight! as! ([Any?]) -> Any?)([4]) as! Int)")
        print("multiply_by_two(8): \((multiplyByTwo! as! ([Any?]) -> Any?)([8]) as! Int)")

        /*
        2. support dynamic-typed value, or has workaround
        */
        let xlList = [
            nil,
            true,
            false,
            "foo",
            0,
            -123,
            123.789,
            -123.789,
            [1, 2, 3],
            ["foo": "bar"],
            { (va: [Any?]) -> Any? in
                var itr = va.makeIterator()
                let aa = itr.next()!! as! Int
                let bb = itr.next()!! as! Int
                return aa * bb as Any?
            }
        ] as [Any?]
        print("xl_list: \(xl.jsonStringify(xlList))")
        print("xl_list: \(xl.jsonStringify(xlList, pretty: true))")
        let xlDict = [
            "xl_none": nil,
            "xl_bool_true": true,
            "xl_bool_false": false,
            "xl_string": "foo",
            "xl_int_positive": 0,
            "xl_int_negative": -123,
            "xl_float_positive": 123.789,
            "xl_float_negative": -123.789,
            "xl_list": [1, 2, 3],
            "xl_dict": ["foo": "bar"],
            "xl_lambda": { (va: [Any?]) -> Any? in
                var itr = va.makeIterator()
                let aa = itr.next()!! as! Int
                let bb = itr.next()!! as! Int
                return aa * bb as Any?
            },
        ] as [String: Any?]
        print("xl_dict: \(xl.jsonStringify(xlDict))")
        print("xl_dict: \(xl.jsonStringify(xlDict, pretty: true))")
    }
}
