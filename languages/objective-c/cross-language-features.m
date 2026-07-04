#import <Foundation/Foundation.h>
#import "../../runtimes/objective-c/runtime/willyhorizont/runtime.m"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /*
        1. support closure as value, or has workaround
        */
        CrossType * sayHello = [[CrossType alloc] initXlClosure:^CrossType * (XlClosureVarArgs * va) {
            CrossType * callbackFunction = [va getNextArguments];
            NSLog(@"hello");
            [callbackFunction call:@[[[CrossType alloc] initXlNone]]];
            return [[CrossType alloc] initXlNone];
        }];
        [sayHello call:@[
            [[CrossType alloc] initXlClosure:^CrossType * (XlClosureVarArgs * va) {
                NSLog(@"world");
                return [[CrossType alloc] initXlNone];
            }],
        ]];
        CrossType * createMultiplier = [[CrossType alloc] initXlClosure:^CrossType * (XlClosureVarArgs * va) {
            CrossType * aa1 = [va getNextArguments];
            __block CrossType * aa = aa1;
            return [[CrossType alloc] initXlClosure:^CrossType * (XlClosureVarArgs * varargsInner) {
                CrossType * bb = [varargsInner getNextArguments];
                return [[CrossType alloc] initXlInt:(toXlInt(aa) * toXlInt(bb))];
            }];
        }];
        CrossType * multiplyByTwo = [createMultiplier call:@[[[CrossType alloc] initXlInt:2]]];
        NSLog(@"multiply_by_two(10): %@", [multiplyByTwo call:@[[[CrossType alloc] initXlInt:10]]]);
        CrossType * multiplyByEight = [createMultiplier call:@[[[CrossType alloc] initXlInt:8]]];
        NSLog(@"multiply_by_eight(4): %@", [multiplyByTwo call:@[[[CrossType alloc] initXlInt:4]]]);
        NSLog(@"multiply_by_two(8): %@", [multiplyByTwo call:@[[[CrossType alloc] initXlInt:8]]]);

        /*
        2. support dynamic-typed value, or has workaround
        */
        CrossType * xlList = initXlList(@[
            [[CrossType alloc] initXlNone],
            [[CrossType alloc] initXlBool:YES],
            [[CrossType alloc] initXlBool:NO],
            [[CrossType alloc] initXlString:@"foo"],
            [[CrossType alloc] initXlInt:0],
            [[CrossType alloc] initXlInt:-123],
            [[CrossType alloc] initXlFloat:123.789],
            [[CrossType alloc] initXlFloat:-123.789],
            initXlList(@[[[CrossType alloc] initXlInt:1], [[CrossType alloc] initXlInt:2], [[CrossType alloc] initXlInt:3]]),
            initXlDict(@{ @"foo" : [[CrossType alloc] initXlString:@"bar"] }),
            [[CrossType alloc] initXlClosure:^CrossType * (XlClosureVarArgs * va) {
                CrossType * aa = [va getNextArguments];
                CrossType * bb = [va getNextArguments];
                return [[CrossType alloc] initXlInt:(toXlInt(aa) * toXlInt(bb))];
            }],
        ]);
        NSLog(@"xl_list: %@", jsonStringify(@[xlList]));
        NSLog(@"xl_list: %@", jsonStringify(@[xlList, initXlDict(@{ @"pretty" : [[CrossType alloc] initXlBool:YES] })]));
        CrossType * xlDict = initXlDict(@{
            @"xl_none" : [[CrossType alloc] initXlNone],
            @"xl_bool_true" : [[CrossType alloc] initXlBool:YES],
            @"xl_bool_false" : [[CrossType alloc] initXlBool:NO],
            @"xl_string" : [[CrossType alloc] initXlString:@"foo"],
            @"xl_int_positive" : [[CrossType alloc] initXlInt:0],
            @"xl_int_negative" : [[CrossType alloc] initXlInt:-123],
            @"xl_float_positive" : [[CrossType alloc] initXlFloat:123.789],
            @"xl_float_negative" : [[CrossType alloc] initXlFloat:-123.789],
            @"xl_list" : initXlList(@[[[CrossType alloc] initXlInt:1], [[CrossType alloc] initXlInt:2], [[CrossType alloc] initXlInt:3]]),
            @"xl_dict" : initXlDict(@{ @"foo" : [[CrossType alloc] initXlString:@"bar"] }),
            @"xl_closure" : [[CrossType alloc] initXlClosure:^CrossType * (XlClosureVarArgs * va) {
                CrossType * aa = [va getNextArguments];
                CrossType * bb = [va getNextArguments];
                return [[CrossType alloc] initXlInt:(toXlInt(aa) * toXlInt(bb))];
            }],
        });
        NSLog(@"xl_dict: %@", jsonStringify(@[xlDict]));
        NSLog(@"xl_dict: %@", jsonStringify(@[xlDict, initXlDict(@{ @"pretty" : [[CrossType alloc] initXlBool:YES] })]));
        CrossType * xlDictIndexed = initXlDict(@{
            @"xl_none" : [[CrossType alloc] initXlNone],
            @"xl_bool_true" : [[CrossType alloc] initXlBool:YES],
            @"xl_bool_false" : [[CrossType alloc] initXlBool:NO],
            @"xl_string" : [[CrossType alloc] initXlString:@"foo"],
            @"xl_int_positive" : [[CrossType alloc] initXlInt:0],
            @"xl_int_negative" : [[CrossType alloc] initXlInt:-123],
            @"xl_float_positive" : [[CrossType alloc] initXlFloat:123.789],
            @"xl_float_negative" : [[CrossType alloc] initXlFloat:-123.789],
            @"xl_list" : initXlList(@[[[CrossType alloc] initXlInt:1], [[CrossType alloc] initXlInt:2], [[CrossType alloc] initXlInt:3]]),
            @"xl_dict" : initXlDict(@{ @"foo" : [[CrossType alloc] initXlString:@"bar"] }),
            @"xl_closure" : [[CrossType alloc] initXlClosure:^CrossType * (XlClosureVarArgs * va) {
                CrossType * aa = [va getNextArguments];
                CrossType * bb = [va getNextArguments];
                return [[CrossType alloc] initXlInt:(toXlInt(aa) * toXlInt(bb))];
            }],
        }, @[
            @"xl_none",
            @"xl_bool_true",
            @"xl_bool_false",
            @"xl_string",
            @"xl_int_positive",
            @"xl_int_negative",
            @"xl_float_positive",
            @"xl_float_negative",
            @"xl_list",
            @"xl_dict" ,
            @"xl_closure",
        ]);
        NSLog(@"xl_dict_indexed: %@", jsonStringify(@[xlDictIndexed]));
        NSLog(@"xl_dict_indexed: %@", jsonStringify(@[xlDictIndexed, initXlDict(@{ @"pretty" : [[CrossType alloc] initXlBool:YES] })]));
    }

    return 0;
}
