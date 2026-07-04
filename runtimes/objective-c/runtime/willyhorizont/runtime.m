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
    XlDictIndexed,
    XlClosure,
    XlIterator
};

@class XL;
@class DictIndexed;

typedef XL * _Nonnull (^Closure)(XL * va);

@interface Iterator : NSObject
@property (nonatomic, strong, readonly) NSArray<XL *> * array;
@property (nonatomic, assign) NSUInteger index;
- (instancetype)initAsList:(NSArray<XL *> *)array;
- (XL *)next;
@end

@interface DictIndexed : NSObject
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> * keys;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, XL *> * dict;
- (void)insertKey:(NSString *)key value:(XL *)value;
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
- (Class)XL;
- (Class)DictIndexed;

- (XL * (^)(void))initNone;
- (XL * (^)(BOOL))initBool;
- (XL * (^)(int64_t))initInt;
- (XL * (^)(double))initFloat;
- (XL * (^)(NSString *))initString;
- (XL * (^)(Closure))initClosure;
- (XL * (^)(NSArray<XL *> * a))initList;
- (XL * (^)(NSDictionary<NSString *, XL *> *, ...))initDict;
- (XL * (^)(XL * a))iter;
- (int64_t (^)(XL *))toXlInt;
- (double (^)(XL *))toXlFloat;
- (NSString * (^)(XL * _Nullable a, id _Nullable o))jsonStringify;
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

@implementation DictIndexed
- (instancetype)init {
    self = [super init];
    if (self) {
        _keys = [NSMutableArray new];
        _dict = [NSMutableDictionary new];
    }
    return self;
}
- (void)insertKey:(NSString *)key value:(XL *)value {
    if (![self.dict objectForKey:key]) {
        [self.keys addObject:key];
    }
    [self.dict setObject:value forKey:key];
}
@end

@interface XL ()
- (instancetype)initAsList:(NSArray<XL *> *)v;
- (instancetype)initAsDict:(NSDictionary<NSString *, XL *> *)v;
- (instancetype)initAsDictIndexed:(DictIndexed *)v;
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
- (instancetype)initAsDictIndexed:(DictIndexed *)v {
    self = [super init];
    if (self) {
        _type = XlDictIndexed;
        _nativeValue = v;
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
        Iterator *l = [[Iterator alloc] initAsList:a];
        XL *el = [[XL alloc] initAsIterator:l];
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
        Iterator *internalItr = (Iterator *)self.nativeValue;
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
        case XlDictIndexed: return [NSString stringWithFormat:@"length: %lu", (unsigned long)[[(DictIndexed *)self.nativeValue dict] count]];
        case XlClosure: return @"[object Function]";
        case XlIterator: return @"[object Function]";
    }
}
@end

@implementation XlNamespace
- (Class)XL {
    return [XL class];
}
- (Class)DictIndexed {
    return [DictIndexed class];
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
    return ^(NSString *v) {
        return [[XL alloc] initString:v];
    };
}
- (XL * (^)(Closure))initClosure {
    return ^(Closure v) {
        return [[XL alloc] initClosure:v];
    };
}
- (XL * (^)(NSArray<XL *> *))initList {
    return ^(NSArray<XL *> *a) { 
        return [[XL alloc] initAsList:a];
    };
}
- (XL * (^)(NSDictionary<NSString *, XL *> *, ...))initDict {
    return ^(NSDictionary<NSString *, XL *> *d, ...) {
        if (!d) return [[XL alloc] initNone];
        
        va_list a;
        va_start(a, d);

        id fA = va_arg(a, id);

        if (fA && [fA isKindOfClass:[NSArray class]]) {
            NSArray<NSString *> *kO = (NSArray<NSString *> *)fA;
            DictIndexed *dI = [DictIndexed new];
            for (NSUInteger i = 0; i < kO.count; i += 1) {
                NSString *key = kO[i];
                XL *value = [d objectForKey:key];
                if (value) [dI insertKey:key value:value];
            }
            va_end(a);
            return [[XL alloc] initAsDictIndexed:dI];
        }

        va_end(a);
        return [[XL alloc] initAsDict:d];
    };
}

- (int64_t (^)(XL *))toXlInt {
    return ^(XL *a) {
        if (!a || a.type != XlInt) {
            @throw [NSException exceptionWithName:@"XlError" reason:@"Error: Expected XlInt." userInfo:nil];
        }
        return (int64_t)[a.nativeValue longLongValue];
    };
}

- (double (^)(XL *))toXlFloat {
    return ^(XL *a) {
        if (!a || a.type != XlFloat) {
            @throw [NSException exceptionWithName:@"XlError" reason:@"Error: Expected XlFloat." userInfo:nil];
        }
        return [a.nativeValue doubleValue];
    };
}

- (XL * (^)(XL *))iter {
    return ^(XL * a) {
        NSArray<XL *> *l = @[];
        if (a && a.type == XlList) {
            l = (NSArray<XL *> *)a.nativeValue;
        }
        Iterator *o = [[Iterator alloc] initAsList:l];
        return [[XL alloc] initAsIterator:o];
    };
}

- (NSString * (^)(XL * _Nullable, id _Nullable))jsonStringify {
    return ^(XL * _Nullable a, id _Nullable oP) {
        XL *frstA = a ? a : [[XL alloc] initNone];
        BOOL p = NO;
        if (oP && [oP isKindOfClass:[XL class]]) {
            XL *o = (XL *)oP;
            if (o.type == XlDict || o.type == XlDictIndexed) {
                NSDictionary<NSString *, XL *> *oD;
                if (o.type == XlDictIndexed) {
                    DictIndexed *dI = (DictIndexed *)o.nativeValue;
                    oD = dI.dict;
                } else {
                    oD = (NSDictionary<NSString *, XL *> *)o.nativeValue;
                }
                XL *pV = oD[@"pretty"];
                if (pV && pV.type == XlBool) {
                    p = [pV.nativeValue boolValue];
                }
            }
        }
        NSString *t = @"    ";
        NSMutableArray<NSDictionary *> *s = [NSMutableArray new];
        [s addObject:@{@"t": @"v", @"v": frstA, @"d": @0}];
        NSMutableString *r = [NSMutableString stringWithString:@""];
        while (s.count > 0) {
            NSDictionary *c = s.lastObject;
            [s removeLastObject];
            NSString *tT = c[@"t"];
            if ([tT isEqualToString:@"r"]) {
                [r appendString:c[@"v"]];
                continue;
            }
            XL *v = c[@"v"];
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
                [r appendFormat:@"\"%@\"", v.nativeValue];
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
                NSArray<XL *> *l = (NSArray<XL *> *)v.nativeValue;
                if (l.count == 0) {
                    [r appendString:@"[]"];
                    continue;
                }
                NSUInteger childT = curT + 1;
                NSString *closeStr = p ? [NSString stringWithFormat:@"\n%@]", [@"" stringByPaddingToLength:(t.length * curT) withString:t startingAtIndex:0]] : @"]";
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
                        NSString *commaStr = p ? [NSString stringWithFormat:@",\n%@", [@"" stringByPaddingToLength:(t.length * childT) withString:t startingAtIndex:0]] : @",";
                        [s addObject:@{
                            @"t": @"r",
                            @"v": commaStr,
                            @"d": @(childT)
                        }];
                    }
                }
                NSString *openStr = p ? [NSString stringWithFormat:@"[\n%@", [@"" stringByPaddingToLength:(t.length * childT) withString:t startingAtIndex:0]] : @"[";
                [s addObject:@{
                    @"t": @"r",
                    @"v": openStr,
                    @"d": @(childT)
                }];
                continue;
            }
            if (v.type == XlDict || v.type == XlDictIndexed) {
                NSArray<NSString *> *keys;
                NSDictionary<NSString *, XL *> *dict;
                if (v.type == XlDictIndexed) {
                    DictIndexed *dI = (DictIndexed *)v.nativeValue;
                    keys = dI.keys;
                    dict = dI.dict;
                } else {
                    NSDictionary<NSString *, XL *> *d = (NSDictionary<NSString *, XL *> *)v.nativeValue;
                    keys = [d allKeys];
                    dict = d;
                }
                if (keys.count == 0) {
                    [r appendString:@"{}"];
                    continue;
                }
                NSUInteger childT = curT + 1;
                NSString *closeStr = p ? [NSString stringWithFormat:@"\n%@}", [@"" stringByPaddingToLength:(t.length * curT) withString:t startingAtIndex:0]] : @"}";
                [s addObject:@{
                    @"t": @"r",
                    @"v": closeStr,
                    @"d": @(curT)
                }];
                for (NSInteger i = (NSInteger)keys.count - 1; i >= 0; i -= 1) {
                    NSString *dk = keys[i];
                    XL *dv = dict[dk];
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
                    NSString *keyStr = p ? [NSString stringWithFormat:@"\"%@\": ", dk] : [NSString stringWithFormat:@"\"%@\":", dk];
                    [s addObject:@{
                        @"t": @"r",
                        @"v": keyStr,
                        @"d": @(childT)
                    }];
                    if (i > 0) {
                        NSString *commaStr = p ? [NSString stringWithFormat:@",\n%@", [@"" stringByPaddingToLength:(t.length * childT) withString:t startingAtIndex:0]] : @",";
                        [s addObject:@{
                            @"t": @"r",
                            @"v": commaStr,
                            @"d": @(childT)
                        }];
                    }
                }
                NSString *openStr = p ? [NSString stringWithFormat:@"{\n%@", [@"" stringByPaddingToLength:(t.length * childT) withString:t startingAtIndex:0]] : @"{";
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
