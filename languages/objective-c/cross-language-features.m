#import <Foundation/Foundation.h>
#import "../../runtimes/objective-c/willyhorizont/runtime/xl.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        XL * sayHello = xl.initClosure(^(XL * args) {
            XL * callbackFunction = [args next];
            NSLog(@"hello");
            [callbackFunction call:@[]];
            return xl.initNone();
        });
        [sayHello call:@[xl.initClosure(^(XL * a) {
            NSLog(@"world");
            return xl.initNone();
        })]];
        XL * createMultiplier = xl.initClosure(^(XL * args) {
            XL * aa = [args next];
            return xl.initClosure(^(XL * args) {
                XL * bb = [args next];
                return xl.initInt(xl.toInt(aa) * xl.toInt(bb));
            });
        });
        XL * multiplyByTwo = [createMultiplier call:@[xl.initInt(2)]];
        NSLog(@"%@", [NSString stringWithFormat:@"multiply_by_two(10): %@", xl.jsonStringify([multiplyByTwo call:@[xl.initInt(10)]], nil)]);
        XL * multiplyByEight = [createMultiplier call:@[xl.initInt(8)]];
        NSLog(@"%@", [NSString stringWithFormat:@"multiply_by_eight(4): %@", xl.jsonStringify([multiplyByEight call:@[xl.initInt(4)]], nil)]);
        NSLog(@"%@", [NSString stringWithFormat:@"multiply_by_two(2): %@", xl.jsonStringify([multiplyByTwo call:@[xl.initInt(2)]], nil)]);
        XL * xlList = xl.initList(@[
            xl.initNone(),
            xl.initBool(YES),
            xl.initBool(NO),
            xl.initString(@"foo"),
            xl.initInt(0),
            xl.initInt(-123),
            xl.initFloat(123.789),
            xl.initFloat(-123.789),
            xl.initList(@[xl.initInt(1), xl.initInt(2), xl.initInt(3)]),
            xl.initDict(@{ @"foo": xl.initString(@"bar") }),
            xl.initClosure(^(XL * args) {
                XL * aa = [args next];
                XL * bb = [args next];
                return xl.initInt(xl.toInt(aa) * xl.toInt(bb));
            }),
        ]);
        NSLog(@"%@", [NSString stringWithFormat:@"xl_list: %@", xl.jsonStringify(xlList, nil)]);
        NSLog(@"%@", [NSString stringWithFormat:@"xl_list: %@", xl.jsonStringify(xlList, xl.initDict(@{ @"pretty": xl.initBool(YES) }))]);
        XL * xlDict = xl.initDict(@{
            @"xl_none": xl.initNone(),
            @"xl_bool_true": xl.initBool(YES),
            @"xl_bool_false": xl.initBool(NO),
            @"xl_string": xl.initString(@"foo"),
            @"xl_int_positive": xl.initInt(0),
            @"xl_int_negative": xl.initInt(-123),
            @"xl_float_positive": xl.initFloat(123.789),
            @"xl_float_negative": xl.initFloat(-123.789),
            @"xl_list": xl.initList(@[xl.initInt(1), xl.initInt(2), xl.initInt(3)]),
            @"xl_dict": xl.initDict(@{ @"foo": xl.initString(@"bar") }),
            @"xl_closure": xl.initClosure(^(XL * args) {
                XL * aa = [args next];
                XL * bb = [args next];
                return xl.initInt(xl.toInt(aa) * xl.toInt(bb));
            }),
        });
        NSLog(@"%@", [NSString stringWithFormat:@"xl_dict: %@", xl.jsonStringify(xlDict, nil)]);
        NSLog(@"%@", [NSString stringWithFormat:@"xl_dict: %@", xl.jsonStringify(xlDict, xl.initDict(@{ @"pretty": xl.initBool(YES) }))]);
    }
    return 0;
}
