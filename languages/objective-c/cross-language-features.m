#import <Foundation/Foundation.h>
#import "../../runtimes/objective-c/runtime/willyhorizont/runtime.m"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /*
        1. support closure as value
        */
        CrossType * sayHello = [[CrossType alloc] initWithXlClosure:^CrossType * (XlClosureVarArgs * varargs) {
            CrossType * callbackFunction = [varargs getNextArguments];
            NSLog(@"hello");
            [callbackFunction call:@[[[CrossType alloc] initWithXlNone]]];
            return [[CrossType alloc] initWithXlNone];
        }];
        [sayHello call:@[
            [[CrossType alloc] initWithXlClosure:^CrossType * (XlClosureVarArgs * varargs) {
                NSLog(@"world");
                return [[CrossType alloc] initWithXlNone];
            }],
        ]];
        CrossType * createMultiplier = [[CrossType alloc] initWithXlClosure:^CrossType * (XlClosureVarArgs * varargs) {
            CrossType * aa = [varargs getNextArguments];
            __block CrossType * aaInner = aa;
            return [[CrossType alloc] initWithXlClosure:^CrossType * (XlClosureVarArgs * varargsInner) {
                CrossType * bb = [varargsInner getNextArguments];
                return [[CrossType alloc] initWithXlInt:toXlInt(aaInner) * toXlInt(bb)];
            }];
        }];
        CrossType * multiplyByTwo = [createMultiplier call:@[[[CrossType alloc] initWithXlInt:2]]];
        NSLog(@"multiply_by_two(10): %@", [multiplyByTwo call:@[[[CrossType alloc] initWithXlInt:10]]]);
        CrossType * multiplyByEight = [createMultiplier call:@[[[CrossType alloc] initWithXlInt:8]]];
        NSLog(@"multiply_by_eight(4): %@", [multiplyByTwo call:@[[[CrossType alloc] initWithXlInt:4]]]);
        NSLog(@"multiply_by_two(8): %@", [multiplyByTwo call:@[[[CrossType alloc] initWithXlInt:8]]]);

        /*
        2. support dynamic-typed value, or has workaround
        */
        CrossType * xlList = toXlList(@[
            [[CrossType alloc] initWithXlNone],
            [[CrossType alloc] initWithXlBool:YES],
            [[CrossType alloc] initWithXlBool:NO],
            [[CrossType alloc] initWithXlString:@"foo"],
            [[CrossType alloc] initWithXlInt:0],
            [[CrossType alloc] initWithXlInt:-123],
            [[CrossType alloc] initWithXlFloat:123.789],
            [[CrossType alloc] initWithXlFloat:-123.789],
            toXlList(@[[[CrossType alloc] initWithXlInt:1], [[CrossType alloc] initWithXlInt:2], [[CrossType alloc] initWithXlInt:3]]),
            toXlDict(@{ @"foo" : [[CrossType alloc] initWithXlString:@"bar"] }),
            [[CrossType alloc] initWithXlClosure:^CrossType * (XlClosureVarArgs * varargs) {
                CrossType * aa = [varargs getNextArguments];
                CrossType * bb = [varargs getNextArguments];
                return [[CrossType alloc] initWithXlInt:toXlInt(aa) * toXlInt(bb)];
            }],
        ]);
        NSLog(@"xl_list: %@", jsonStringify(@[xlList]));
        NSLog(@"xl_list: %@", jsonStringify(@[xlList, toXlDict(@{ @"pretty" : [[CrossType alloc] initWithXlBool:YES] })]));
        CrossType * xlDict = toXlDict(@{
            @"xl_none" : [[CrossType alloc] initWithXlNone],
            @"xl_bool_true" : [[CrossType alloc] initWithXlBool:YES],
            @"xl_bool_false" : [[CrossType alloc] initWithXlBool:NO],
            @"xl_string" : [[CrossType alloc] initWithXlString:@"foo"],
            @"xl_int_positive" : [[CrossType alloc] initWithXlInt:0],
            @"xl_int_negative" : [[CrossType alloc] initWithXlInt:-123],
            @"xl_float_positive" : [[CrossType alloc] initWithXlFloat:123.789],
            @"xl_float_negative" : [[CrossType alloc] initWithXlFloat:-123.789],
            @"xl_list" : toXlList(@[[[CrossType alloc] initWithXlInt:1], [[CrossType alloc] initWithXlInt:2], [[CrossType alloc] initWithXlInt:3]]),
            @"xl_dict" : toXlDict(@{ @"foo" : [[CrossType alloc] initWithXlString:@"bar"] }),
            @"xl_closure" : [[CrossType alloc] initWithXlClosure:^CrossType * (XlClosureVarArgs * varargs) {
                CrossType * aa = [varargs getNextArguments];
                CrossType * bb = [varargs getNextArguments];
                return [[CrossType alloc] initWithXlInt:toXlInt(aa) * toXlInt(bb)];
            }],
        });
        NSLog(@"xl_dict: %@", jsonStringify(@[xlDict]));
        NSLog(@"xl_dict: %@", jsonStringify(@[xlDict, toXlDict(@{ @"pretty" : [[CrossType alloc] initWithXlBool:YES] })]));
        CrossType * xlDictIndexed = toXlDict(@{
            @"xl_none" : [[CrossType alloc] initWithXlNone],
            @"xl_bool_true" : [[CrossType alloc] initWithXlBool:YES],
            @"xl_bool_false" : [[CrossType alloc] initWithXlBool:NO],
            @"xl_string" : [[CrossType alloc] initWithXlString:@"foo"],
            @"xl_int_positive" : [[CrossType alloc] initWithXlInt:0],
            @"xl_int_negative" : [[CrossType alloc] initWithXlInt:-123],
            @"xl_float_positive" : [[CrossType alloc] initWithXlFloat:123.789],
            @"xl_float_negative" : [[CrossType alloc] initWithXlFloat:-123.789],
            @"xl_list" : toXlList(@[[[CrossType alloc] initWithXlInt:1], [[CrossType alloc] initWithXlInt:2], [[CrossType alloc] initWithXlInt:3]]),
            @"xl_dict" : toXlDict(@{ @"foo" : [[CrossType alloc] initWithXlString:@"bar"] }),
            @"xl_closure" : [[CrossType alloc] initWithXlClosure:^CrossType * (XlClosureVarArgs * varargs) {
                CrossType * aa = [varargs getNextArguments];
                CrossType * bb = [varargs getNextArguments];
                return [[CrossType alloc] initWithXlInt:toXlInt(aa) * toXlInt(bb)];
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
        NSLog(@"xl_dict_indexed: %@", jsonStringify(@[xlDictIndexed, toXlDict(@{ @"pretty" : [[CrossType alloc] initWithXlBool:YES] })]));
    }

    return 0;
}
