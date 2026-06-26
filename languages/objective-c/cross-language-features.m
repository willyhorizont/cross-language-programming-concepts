#import <Foundation/Foundation.h>
#import "../../runtimes/objective-c/runtime/willyhorizont/runtime.m"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /*
        1. support closure as value
        */
        CrossType * sayHello = [[CrossType alloc] initWithClosure:^CrossType * (XlClosureVarArgs * varargs) {
            CrossType * callbackFunction = [varargs getNextArguments];
            NSLog(@"hello");
            [callbackFunction call:@[[[CrossType alloc] initWithXlNone]]];
            return [[CrossType alloc] initWithXlNone];
        }];
        [sayHello call:@[
            [[CrossType alloc] initWithClosure:^CrossType * (XlClosureVarArgs * varargs) {
                NSLog(@"world");
                return [[CrossType alloc] initWithXlNone];
            }],
        ]];
        CrossType * createMultiplier = [[CrossType alloc] initWithClosure:^CrossType * (XlClosureVarArgs * varargs) {
            CrossType * aa = [varargs getNextArguments];
            __block CrossType * aaInner = aa;
            return [[CrossType alloc] initWithClosure:^CrossType * (XlClosureVarArgs * varargsInner) {
                CrossType * bb = [varargsInner getNextArguments];
                return [[CrossType alloc] initWithInt:toXlInt(aaInner) * toXlInt(bb)];
            }];
        }];
        CrossType * multiplyByTwo = [createMultiplier call:@[[[CrossType alloc] initWithInt:2]]];
        NSLog(@"multiply_by_two(10): %@", [multiplyByTwo call:@[[[CrossType alloc] initWithInt:10]]]);
        CrossType * multiplyByEight = [createMultiplier call:@[[[CrossType alloc] initWithInt:8]]];
        NSLog(@"multiply_by_eight(4): %@", [multiplyByTwo call:@[[[CrossType alloc] initWithInt:4]]]);
        NSLog(@"multiply_by_two(8): %@", [multiplyByTwo call:@[[[CrossType alloc] initWithInt:8]]]);

        /*
        2. support dynamic-typed value, or has workaround
        */
        CrossType * xlList = toXlList(@[
            [[CrossType alloc] initWithXlNone],
            [[CrossType alloc] initWithBool:YES],
            [[CrossType alloc] initWithBool:NO],
            [[CrossType alloc] initWithString:@"foo"],
            [[CrossType alloc] initWithInt:0],
            [[CrossType alloc] initWithInt:-123],
            [[CrossType alloc] initWithFloat:123.789],
            [[CrossType alloc] initWithFloat:-123.789],
            toXlList(@[[[CrossType alloc] initWithInt:1], [[CrossType alloc] initWithInt:2], [[CrossType alloc] initWithInt:3]]),
            toXlDict(@{ @"foo" : [[CrossType alloc] initWithString:@"bar"] }),
            [[CrossType alloc] initWithClosure:^CrossType * (XlClosureVarArgs * varargs) {
                CrossType * aa = [varargs getNextArguments];
                CrossType * bb = [varargs getNextArguments];
                return [[CrossType alloc] initWithInt:toXlInt(aa) * toXlInt(bb)];
            }],
        ]);
        NSLog(@"xl_list: %@", jsonStringify(@[xlList]));
        NSLog(@"xl_list: %@", jsonStringify(@[xlList, toXlDict(@{ @"pretty" : [[CrossType alloc] initWithBool:YES] })]));
        CrossType * xlDict = toXlDict(@{
            @"xl_none" : [[CrossType alloc] initWithXlNone],
            @"xl_bool_true" : [[CrossType alloc] initWithBool:YES],
            @"xl_bool_false" : [[CrossType alloc] initWithBool:NO],
            @"xl_string" : [[CrossType alloc] initWithString:@"foo"],
            @"xl_int_positive" : [[CrossType alloc] initWithInt:0],
            @"xl_int_negative" : [[CrossType alloc] initWithInt:-123],
            @"xl_float_positive" : [[CrossType alloc] initWithFloat:123.789],
            @"xl_float_negative" : [[CrossType alloc] initWithFloat:-123.789],
            @"xl_list" : toXlList(@[[[CrossType alloc] initWithInt:1], [[CrossType alloc] initWithInt:2], [[CrossType alloc] initWithInt:3]]),
            @"xl_dict" : toXlDict(@{ @"foo" : [[CrossType alloc] initWithString:@"bar"] }),
            @"xl_closure" : [[CrossType alloc] initWithClosure:^CrossType * (XlClosureVarArgs * varargs) {
                CrossType * aa = [varargs getNextArguments];
                CrossType * bb = [varargs getNextArguments];
                return [[CrossType alloc] initWithInt:toXlInt(aa) * toXlInt(bb)];
            }],
        });
        NSLog(@"xl_dict: %@", jsonStringify(@[xlDict]));
        NSLog(@"xl_dict: %@", jsonStringify(@[xlDict, toXlDict(@{ @"pretty" : [[CrossType alloc] initWithBool:YES] })]));
    }

    return 0;
}
