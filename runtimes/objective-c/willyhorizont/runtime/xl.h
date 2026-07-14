#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XlType) {
    XlNone,
    XlBool,
    XlInt,
    XlFloat,
    XlString,
    XlList,
    XlDict,
    XlClosure,
    XlIterator
};

@class XL;

typedef XL * _Nonnull (^Closure)(XL * va);

@interface Iterator : NSObject
@property (nonatomic, strong, readonly) NSArray<XL *> * array;
@property (nonatomic, assign) NSUInteger index;
- (instancetype)initAsList:(NSArray<XL *> *)array;
- (XL *)next;
@end

@interface XL : NSObject
@property (nonatomic, assign, readonly) XlType type;
@property (nonatomic, strong, readonly) id nativeValue;
- (instancetype)initNone;
- (instancetype)initBool:(BOOL)v;
- (instancetype)initInt:(int64_t)v;
- (instancetype)initFloat:(double)v;
- (instancetype)initString:(NSString *)v;
- (instancetype)initClosure:(Closure)v;
- (XL *)call:(NSArray<XL *> *)a;
- (XL *)next;
@end

@interface XlNamespace : NSObject
+ (NSString *)escapeString:(NSString *)s;
- (Class)XL;
- (XL * (^)(void))initNone;
- (XL * (^)(BOOL))initBool;
- (XL * (^)(int64_t))initInt;
- (XL * (^)(double))initFloat;
- (XL * (^)(NSString *))initString;
- (XL * (^)(Closure))initClosure;
- (XL * (^)(NSArray<XL *> * a))initList;
- (XL * (^)(NSDictionary<NSString *, XL *> *))initDict;
- (XL * (^)(XL * a))iter;
- (int64_t (^)(XL *))toInt;
- (double (^)(XL *))toFloat;
- (NSString * (^)(XL * _Nullable, id _Nullable))jsonStringify;
@end

extern XlNamespace * xl;

@implementation Iterator
- (instancetype)initAsList:(NSArray<XL *> *)array {
    self = [super init];
    if (self) { _array = array; _index = 0; }
    return self;
}
- (XL *)next {
    if (_index < self.array.count) {
        XL * arg = self.array[_index];
        _index += 1;
        return arg;
    }
    return [[XL alloc] initNone];
}
@end

@interface XL ()
- (instancetype)initAsList:(NSArray<XL *> *)v;
- (instancetype)initAsDict:(NSDictionary<NSString *, XL *> *)v;
- (instancetype)initAsIterator:(Iterator *)v;
@end

@implementation XL
- (instancetype)initNone {
    self = [super init];
    if (self) {
        _type = XlNone;
        _nativeValue = [NSNull null];
    }
    return self;
}
- (instancetype)initBool:(BOOL)v {
    self = [super init];
    if (self) {
        _type = XlBool;
        _nativeValue = @(v);
    }
    return self;
}
- (instancetype)initInt:(int64_t)v {
    self = [super init];
    if (self) {
        _type = XlInt;
        _nativeValue = @(v);
    }
    return self;
}
- (instancetype)initFloat:(double)v {
    self = [super init];
    if (self) {
        _type = XlFloat;
        _nativeValue = @(v);
    }
    return self;
}
- (instancetype)initString:(NSString *)v {
    self = [super init];
    if (self) {
        _type = XlString;
        _nativeValue = [v copy];
    }
    return self;
}
- (instancetype)initAsList:(NSArray<XL *> *)v {
    self = [super init];
    if (self) {
        _type = XlList;
        _nativeValue = [v copy];
    }
    return self;
}
- (instancetype)initAsDict:(NSDictionary<NSString *, XL *> *)v {
    self = [super init];
    if (self) {
        _type = XlDict;
        _nativeValue = [v copy];
    }
    return self;
}
- (instancetype)initClosure:(Closure)v {
    self = [super init];
    if (self) {
        _type = XlClosure;
        _nativeValue = [v copy];
    }
    return self;
}
- (XL *)call:(NSArray<XL *> *)a {
    if (self.type == XlClosure) {
        Closure cB = (Closure)self.nativeValue;
        Iterator * l = [[Iterator alloc] initAsList:a];
        XL * el = [[XL alloc] initAsIterator:l];
        return cB(el);
    }
    @throw [NSException exceptionWithName:@"XlRuntimeError" reason:@"Error: Expected Closure." userInfo:nil];
}
- (instancetype)initAsIterator:(Iterator *)v {
    self = [super init];
    if (self) {
        _type = XlIterator;
        _nativeValue = v;
    }
    return self;
}
- (XL *)next {
    if (self.type == XlIterator) {
        Iterator * internalItr = (Iterator *)self.nativeValue;
        return [internalItr next];
    }
    @throw [NSException exceptionWithName:@"XlRuntimeError" reason:@"Error: Expected XlIterator." userInfo:nil];
}
- (NSString *)description {
    switch (self.type) {
        case XlNone: return @"null";
        case XlBool: return [self.nativeValue boolValue] ? @"true" : @"false";
        case XlInt: return [NSString stringWithFormat:@"%@", self.nativeValue];
        case XlFloat: return [NSString stringWithFormat:@"%@", self.nativeValue];
        case XlString: return (NSString *)self.nativeValue;
        case XlList: return [NSString stringWithFormat:@"length: %lu", (unsigned long)[self.nativeValue count]];
        case XlDict: return [NSString stringWithFormat:@"length: %lu", (unsigned long)[self.nativeValue count]];
        case XlClosure: return @"[object Function]";
        case XlIterator: return @"[object Function]";
    }
}
@end

@implementation XlNamespace
- (Class)XL {
    return [XL class];
}

- (XL * (^)(void))initNone {
    return ^{
        return [[XL alloc] initNone];
    };
}
- (XL * (^)(BOOL))initBool {
    return ^(BOOL v) {
        return [[XL alloc] initBool:v];
    };
}
- (XL * (^)(int64_t))initInt {
    return ^(int64_t v) {
        return [[XL alloc] initInt:v];
    };
}
- (XL * (^)(double))initFloat {
    return ^(double v) {
        return [[XL alloc] initFloat:v];
    };
}
- (XL * (^)(NSString *))initString {
    return ^(NSString * v) {
        return [[XL alloc] initString:v];
    };
}
- (XL * (^)(Closure))initClosure {
    return ^(Closure v) {
        return [[XL alloc] initClosure:v];
    };
}
- (XL * (^)(NSArray<XL *> *))initList {
    return ^(NSArray<XL *> * v) {
        return [[XL alloc] initAsList:v];
    };
}
- (XL * (^)(NSDictionary<NSString *, XL *> *))initDict {
    return ^(NSDictionary<NSString *, XL *> * v) {
        return [[XL alloc] initAsDict:v];
    };
}

- (int64_t (^)(XL *))toInt {
    return ^(XL * a) {
        if (!a || a.type != XlInt) {
            @throw [NSException exceptionWithName:@"XlError" reason:@"Error: Expected XlInt." userInfo:nil];
        }
        return (int64_t)[a.nativeValue longLongValue];
    };
}

- (double (^)(XL *))toFloat {
    return ^(XL * a) {
        if (!a || a.type != XlFloat) {
            @throw [NSException exceptionWithName:@"XlError" reason:@"Error: Expected XlFloat." userInfo:nil];
        }
        return [a.nativeValue doubleValue];
    };
}

- (XL * (^)(XL *))iter {
    return ^(XL * a) {
        NSArray<XL *> * l = @[];
        if (a && a.type == XlList) {
            l = (NSArray<XL *> *)a.nativeValue;
        }
        Iterator * o = [[Iterator alloc] initAsList:l];
        return [[XL alloc] initAsIterator:o];
    };
}

+ (NSString *)escapeString:(NSString *)s {
    if (!s) return @"";
    NSMutableString *r = [s mutableCopy];
    [r replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, r.length)];
    [r replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, r.length)];
    [r replaceOccurrencesOfString:@"\n" withString:@"\\n" options:0 range:NSMakeRange(0, r.length)];
    [r replaceOccurrencesOfString:@"\r" withString:@"\\r" options:0 range:NSMakeRange(0, r.length)];
    [r replaceOccurrencesOfString:@"\t" withString:@"\\t" options:0 range:NSMakeRange(0, r.length)];
    return [r copy];
}

- (NSString * (^)(XL * _Nullable, id _Nullable))jsonStringify {
    return ^(XL * _Nullable a, id _Nullable oP) {
        XL * frstA = a ? a : [[XL alloc] initNone];
        BOOL p = NO;
        if (oP && [oP isKindOfClass:[XL class]]) {
            XL * o = (XL *)oP;
            if (o.type == XlDict) {
                NSDictionary<NSString *, XL *> * oD = (NSDictionary<NSString *, XL *> *)o.nativeValue;
                XL * pV = oD[@"pretty"];
                if (pV && pV.type == XlBool) {
                    p = [pV.nativeValue boolValue];
                }
            }
        }
        NSString * t = @"    ";
        NSMutableArray<NSDictionary *> * s = [NSMutableArray new];
        [s addObject:@{@"t": @"v", @"v": frstA, @"d": @0}];
        NSMutableString * r = [NSMutableString stringWithString:@""];
        while (s.count > 0) {
            NSDictionary * c = s.lastObject;
            [s removeLastObject];
            NSString * tT = c[@"t"];
            if ([tT isEqualToString:@"r"]) {
                [r appendString:c[@"v"]];
                continue;
            }
            XL * v = c[@"v"];
            NSUInteger curT = [c[@"d"] unsignedIntegerValue];
            if (v.type == XlNone) {
                [r appendString:@"null"];
                continue;
            }
            if (v.type == XlBool) {
                [r appendString:[v.nativeValue boolValue] ? @"true" : @"false"];
                continue;
            }
            if (v.type == XlString) {
                [r appendFormat:@"\"%@\"", [XlNamespace escapeString:(NSString *)v.nativeValue]];
                continue;
            }
            if (v.type == XlInt || v.type == XlFloat) {
                [r appendFormat:@"%@", v.nativeValue];
                continue;
            }
            if (v.type == XlClosure) {
                [r appendString:@"\"[object Function]\""];
                continue;
            }
            if (v.type == XlList) {
                NSArray<XL *> * l = (NSArray<XL *> *)v.nativeValue;
                if (l.count == 0) {
                    [r appendString:@"[]"];
                    continue;
                }
                NSUInteger childT = curT + 1;
                NSString * closeStr = p ? [NSString stringWithFormat:@"\n%@]", [@"" stringByPaddingToLength:(t.length * curT) withString:t startingAtIndex:0]] : @"]";
                [s addObject:@{
                    @"t": @"r",
                    @"v": closeStr,
                    @"d": @(curT)
                }];
                for (NSInteger i = (NSInteger)l.count - 1; i >= 0; i -= 1) {
                    [s addObject:@{
                        @"t": @"v",
                        @"v": l[i],
                        @"d": @(childT)
                    }];
                    if (i > 0) {
                        NSString * commaStr = p ? [NSString stringWithFormat:@",\n%@", [@"" stringByPaddingToLength:(t.length * childT) withString:t startingAtIndex:0]] : @",";
                        [s addObject:@{
                            @"t": @"r",
                            @"v": commaStr,
                            @"d": @(childT)
                        }];
                    }
                }
                NSString * openStr = p ? [NSString stringWithFormat:@"[\n%@", [@"" stringByPaddingToLength:(t.length * childT) withString:t startingAtIndex:0]] : @"[";
                [s addObject:@{
                    @"t": @"r",
                    @"v": openStr,
                    @"d": @(childT)
                }];
                continue;
            }
            if (v.type == XlDict) {
                NSDictionary<NSString *, XL *> * d = (NSDictionary<NSString *, XL *> *)v.nativeValue;
                NSArray<NSString *> * k = [d allKeys];
                if (k.count == 0) {
                    [r appendString:@"{}"];
                    continue;
                }
                NSUInteger childT = curT + 1;
                NSString * closeStr = p ? [NSString stringWithFormat:@"\n%@}", [@"" stringByPaddingToLength:(t.length * curT) withString:t startingAtIndex:0]] : @"}";
                [s addObject:@{
                    @"t": @"r",
                    @"v": closeStr,
                    @"d": @(curT)
                }];
                for (NSInteger i = (NSInteger)k.count - 1; i >= 0; i -= 1) {
                    NSString * dk = k[i];
                    XL * dv = d[dk];
                    if (dv) {
                        [s addObject:@{
                            @"t": @"v",
                            @"v": dv,
                            @"d": @(childT)
                        }];
                    } else {
                        [s addObject:@{
                            @"t": @"v",
                            @"v": [[XL alloc] initNone],
                            @"d": @(childT)
                        }];
                    }
                    NSString * keyStr = p ? [NSString stringWithFormat:@"\"%@\": ", dk] : [NSString stringWithFormat:@"\"%@\":", dk];
                    [s addObject:@{
                        @"t": @"r",
                        @"v": keyStr,
                        @"d": @(childT)
                    }];
                    if (i > 0) {
                        NSString * commaStr = p ? [NSString stringWithFormat:@",\n%@", [@"" stringByPaddingToLength:(t.length * childT) withString:t startingAtIndex:0]] : @",";
                        [s addObject:@{
                            @"t": @"r",
                            @"v": commaStr,
                            @"d": @(childT)
                        }];
                    }
                }
                NSString * openStr = p ? [NSString stringWithFormat:@"{\n%@", [@"" stringByPaddingToLength:(t.length * childT) withString:t startingAtIndex:0]] : @"{";
                [s addObject:@{
                    @"t": @"r",
                    @"v": openStr,
                    @"d": @(childT)
                }];
                continue;
            }
            [r appendString:@"\"[object Object]\""];
        }
        return [r copy];
    };
}

@end

XlNamespace * xl;
__attribute__((constructor)) static void initialize_xl_namespace() {
    xl = [XlNamespace new];
}

NS_ASSUME_NONNULL_END
