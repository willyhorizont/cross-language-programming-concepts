#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CrossTypeKind) {
    XlKindNone,
    XlKindBool,
    XlKindInt,
    XlKindFloat,
    XlKindString,
    XlKindList,
    XlKindDict,
    XlKindDictIndexed,
    XlKindClosure
};

@class CrossType;
@class XlDictIndexed;
@class XlClosureVarArgs;
@class JsonSfyTok;

int64_t toXlInt(CrossType * a);
double toXlFloat(CrossType * a);
CrossType * initXlList(NSArray<CrossType *> * a);
CrossType * initXlDict(NSDictionary<NSString *, CrossType *> * d, ...);
NSString * stringRepeat(NSString * s, NSUInteger n);
NSString * jsonStringify(NSArray *a);

@interface XlClosureVarArgs : NSObject
@property (nonatomic, strong, readonly) NSArray<CrossType *> * va;
@property (nonatomic, assign, readonly) NSUInteger i;
- (instancetype)initWithXlClosureVarArgs:(NSArray<CrossType *> *)a;
- (CrossType *)getNextArguments;
@end

typedef CrossType * (^XlClosure)(XlClosureVarArgs * va);

@interface XlDictIndexed : NSObject
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> * keys;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, CrossType *> * map;
- (void)insertKey:(NSString *)key value:(CrossType *)value;
@end

@interface CrossType : NSObject
@property (nonatomic, assign, readonly) CrossTypeKind kind;
@property (nonatomic, strong, readonly) id rawValue;
- (instancetype)initXlNone;
- (instancetype)initXlBool:(BOOL)v;
- (instancetype)initXlInt:(int64_t)v;
- (instancetype)initXlFloat:(double)v;
- (instancetype)initXlString:(NSString *)v;
- (instancetype)initXlClosure:(XlClosure)v;
- (instancetype)initWithXlList:(NSArray<CrossType *> *)v;
- (instancetype)initWithXlDict:(NSDictionary<NSString *, CrossType *> *)v;
- (instancetype)initWithXlDictIndexed:(XlDictIndexed *)v;
- (CrossType *)call:(NSArray<CrossType *> *)a;
@end

@interface JsonSfyTok : NSObject
@property (nonatomic, strong) NSString * t; // @"ref" or @"raw"
@property (nonatomic, strong) CrossType * v;
@property (nonatomic, strong) NSString * rv;
@property (nonatomic, assign) NSUInteger d;
@end

@implementation XlClosureVarArgs
- (instancetype)initWithXlClosureVarArgs:(NSArray<CrossType *> *)a {
    self = [super init];
    if (self) {
        _va = a;
        _i = 0;
    }
    return self;
}
- (CrossType *)getNextArguments {
    if (_i < self.va.count) {
        CrossType * arg = self.va[_i];
        _i += 1;
        return arg;
    }
    return [[CrossType alloc] initXlNone];
}
@end

@implementation XlDictIndexed
- (instancetype)init {
    self = [super init];
    if (self) {
        _keys = [NSMutableArray new]; _map = [NSMutableDictionary new];
    }
    return self;
}
- (void)insertKey:(NSString *)key value:(CrossType *)value {
    if (![self.map objectForKey:key]) {
        [self.keys addObject:key];
    }
    [self.map setObject:value forKey:key];
}
@end

@implementation CrossType
- (instancetype)initXlNone {
    self = [super init];
    if (self) {
        _kind = XlKindNone; _rawValue = [NSNull null];
    }
    return self;
}
- (instancetype)initXlBool:(BOOL)v {
    self = [super init];
    if (self) {
        _kind = XlKindBool; _rawValue = @(v);
    }
    return self;
}
- (instancetype)initXlInt:(int64_t)v {
    self = [super init];
    if (self) {
        _kind = XlKindInt; _rawValue = @(v);
    }
    return self;
}
- (instancetype)initXlFloat:(double)v {
    self = [super init];
    if (self) {
        _kind = XlKindFloat; _rawValue = @(v);
    }
    return self;
}
- (instancetype)initXlString:(NSString *)v {
    self = [super init];
    if (self) {
        _kind = XlKindString; _rawValue = [v copy];
    }
    return self;
}
- (instancetype)initXlClosure:(XlClosure)v {
    self = [super init];
    if (self) {
        _kind = XlKindClosure; _rawValue = [v copy];
    }
    return self;
}
- (CrossType *)call:(NSArray<CrossType *> *)a {
    if (self.kind == XlKindClosure) {
        XlClosure cB = (XlClosure)self.rawValue;
        XlClosureVarArgs * va = [[XlClosureVarArgs alloc] initWithXlClosureVarArgs:a];
        return cB(va);
    }
    @throw [NSException exceptionWithName:@"XlRuntimeError" reason:@"Error: Expected XlClosure." userInfo:nil];
}
- (instancetype)initWithXlList:(NSArray<CrossType *> *)v {
    self = [super init];
    if (self) {
        _kind = XlKindList; _rawValue = [v copy];
    }
    return self;
}
- (instancetype)initWithXlDict:(NSDictionary<NSString *, CrossType *> *)v {
    self = [super init];
    if (self) {
        _kind = XlKindDict; _rawValue = [v copy];
    }
    return self;
}
- (instancetype)initWithXlDictIndexed:(XlDictIndexed *)v {
    self = [super init];
    if (self) {
        _kind = XlKindDictIndexed; _rawValue = v;
    }
    return self;
}
- (NSString *)description {
    switch (self.kind) {
        case XlKindNone: return @"None";
        case XlKindBool: return [self.rawValue boolValue] ? @"True" : @"False";
        case XlKindInt: return [NSString stringWithFormat:@"%@", self.rawValue];
        case XlKindFloat: return [NSString stringWithFormat:@"%@", self.rawValue];
        case XlKindString: return (NSString *)self.rawValue;
        case XlKindList: return [NSString stringWithFormat:@"List count: %lu", (unsigned long)[self.rawValue count]];
        case XlKindDict: return [NSString stringWithFormat:@"Dict size: %lu", (unsigned long)[self.rawValue count]];
        case XlKindDictIndexed: return [NSString stringWithFormat:@"IndexedDict size: %lu", (unsigned long)[[(XlDictIndexed *)self.rawValue map] count]];
        case XlKindClosure: return @"Closure Block";
    }
}
@end

int64_t toXlInt(CrossType * a) {
    if (!a || a.kind == XlKindNone) {
        @throw [NSException exceptionWithName:@"CrossTypeError" reason:@"Error: Expected XlInt." userInfo:nil];
    }
    if (a.kind != XlKindInt) {
        @throw [NSException exceptionWithName:@"CrossTypeError" reason:@"Error: Expected XlInt." userInfo:nil];
    }
    return [a.rawValue longLongValue];
}

double toXlFloat(CrossType * a) {
    if (!a || a.kind == XlKindNone) {
        @throw [NSException exceptionWithName:@"CrossTypeError" reason:@"Error: Expected XlFloat." userInfo:nil];
    }
    if (a.kind != XlKindFloat) {
        @throw [NSException exceptionWithName:@"CrossTypeError" reason:@"Error: Expected XlFloat." userInfo:nil];
    }
    return [a.rawValue doubleValue];
}

CrossType * initXlList(NSArray<CrossType *> * a) {
    return [[CrossType alloc] initWithXlList:a];
}

CrossType * initXlDict(NSDictionary<NSString *, CrossType *> * d, ...) {
    if (!d) {
        return [[CrossType alloc] initXlNone];
    }

    va_list a;
    va_start(a, d);
    
    NSArray<NSString *> *kO = va_arg(a, NSArray<NSString *> *);
    va_end(a);

    if (kO && [kO isKindOfClass:[NSArray class]]) {
        XlDictIndexed *dI = [XlDictIndexed new];
        
        for (NSUInteger i = 0; i < kO.count; i += 1) {
            NSString *key = kO[i];
            CrossType *value = [d objectForKey:key];
            
            if (value) {
                [dI insertKey:key value:value];
            }
        }
        return [[CrossType alloc] initWithXlDictIndexed:dI];
    }

    return [[CrossType alloc] initWithXlDict:d];
}

NSString * stringRepeat(NSString * s, NSUInteger n) {
    return [@"" stringByPaddingToLength:(s.length * n) withString:s startingAtIndex:0];
}

@implementation JsonSfyTok
@end

NSString * jsonStringify(NSArray *a) {
    if (!a || a.count == 0) {
        return @"";
    }

    CrossType *va = a[0];

    BOOL p = NO;
    if (a.count > 1) {
        CrossType *o = a[1];
        if (o && o.kind == XlKindDict) {
            NSDictionary<NSString *, CrossType *> *d = (NSDictionary<NSString *, CrossType *> *)o.rawValue;
            CrossType *pV = [d objectForKey:@"pretty"];
            if (pV && pV.kind == XlKindBool) {
                p = [pV.rawValue boolValue];
            }
        }
    }

    NSString * t = @"    ";
    NSMutableArray<JsonSfyTok *> * s = [[NSMutableArray alloc] init];
    
    JsonSfyTok * tokRt = [[JsonSfyTok alloc] init];
    tokRt.t = @"ref";
    tokRt.v = va;
    tokRt.rv = @"";
    tokRt.d = 0;
    [s addObject:tokRt];
    
    NSMutableString * r = [[NSMutableString alloc] init];
    
    while (s.count > 0) {
        JsonSfyTok * c = s.lastObject;
        [s removeLastObject];
        
        if ([c.t isEqualToString:@"raw"]) {
            [r appendString:c.rv];
            continue;
        }
        
        NSUInteger curT = c.d;
        CrossType * el = c.v;
        
        if (el.kind == XlKindNone) {
            [r appendString:@"null"];
            continue;
        }
        
        if (el.kind == XlKindString) {
            [r appendFormat:@"\"%@\"", el.rawValue];
            continue;
        }
        
        if (el.kind == XlKindBool) {
            [r appendString:[el.rawValue boolValue] ? @"true" : @"false"];
            continue;
        }
        
        if (el.kind == XlKindInt || el.kind == XlKindFloat) {
            [r appendFormat:@"%@", el.rawValue];
            continue;
        }
        
        if (el.kind == XlKindList) {
            NSArray<CrossType *> * lR = (NSArray<CrossType *> *)el.rawValue;
            if (lR.count == 0) {
                [r appendString:@"[]"];
                continue;
            }
            
            NSUInteger childT = curT + 1;
            
            JsonSfyTok * tokCls = [[JsonSfyTok alloc] init];
            tokCls.t = @"raw";
            tokCls.rv = p ? 
                [NSString stringWithFormat:@"\n%@]", stringRepeat(t, curT)] : @"]";
            tokCls.d = curT;
            [s addObject:tokCls];
            
            for (NSInteger i = (NSInteger)lR.count - 1; i >= 0; i -= 1) {
                JsonSfyTok * tokLsEl = [[JsonSfyTok alloc] init];
                tokLsEl.t = @"ref";
                tokLsEl.v = lR[i];
                tokLsEl.d = childT;
                [s addObject:tokLsEl];
                
                if (i > 0) {
                    JsonSfyTok * tokCom = [[JsonSfyTok alloc] init];
                    tokCom.t = @"raw";
                    tokCom.rv = p ? 
                        [NSString stringWithFormat:@",\n%@", stringRepeat(t, childT)] : @", ";
                    tokCom.d = childT;
                    [s addObject:tokCom];
                }
            }
            
            JsonSfyTok * tokOpn = [[JsonSfyTok alloc] init];
            tokOpn.t = @"raw";
            tokOpn.rv = p ? 
                [NSString stringWithFormat:@"[\n%@", stringRepeat(t, childT)] : @"[";
            tokOpn.d = childT;
            [s addObject:tokOpn];
            continue;
        }
        
        if (el.kind == XlKindDictIndexed) {
            XlDictIndexed * xlDictIndexedRef = (XlDictIndexed *)el.rawValue;
            if (xlDictIndexedRef.keys.count == 0) {
                [r appendString:@"{}"];
                continue;
            }
            
            NSUInteger childT = curT + 1;
            
            JsonSfyTok * tokCls = [[JsonSfyTok alloc] init];
            tokCls.t = @"raw";
            tokCls.rv = p ? 
                [NSString stringWithFormat:@"\n%@}", stringRepeat(t, curT)] : @" }";
            tokCls.d = curT;
            [s addObject:tokCls];
            
            for (NSInteger i = (NSInteger)xlDictIndexedRef.keys.count - 1; i >= 0; i -= 1) {
                NSString * key = xlDictIndexedRef.keys[i];
                CrossType * val = [xlDictIndexedRef.map objectForKey:key];
                
                JsonSfyTok * tokDi = [[JsonSfyTok alloc] init];
                tokDi.t = @"ref";
                tokDi.v = val;
                tokDi.d = childT;
                [s addObject:tokDi];
                
                JsonSfyTok * tokDk = [[JsonSfyTok alloc] init];
                tokDk.t = @"raw";
                tokDk.rv = [NSString stringWithFormat:@"\"%@\": ", key];
                tokDk.d = childT;
                [s addObject:tokDk];
                
                if (i > 0) {
                    JsonSfyTok * tokCom = [[JsonSfyTok alloc] init];
                    tokCom.t = @"raw";
                    tokCom.rv = p ? 
                        [NSString stringWithFormat:@",\n%@", stringRepeat(t, childT)] : @", ";
                    tokCom.d = childT;
                    [s addObject:tokCom];
                }
            }
            
            JsonSfyTok * tokOpn = [[JsonSfyTok alloc] init];
            tokOpn.t = @"raw";
            tokOpn.rv = p ? 
                [NSString stringWithFormat:@"{\n%@", stringRepeat(t, childT)] : @"{ ";
            tokOpn.d = childT;
            [s addObject:tokOpn];
            continue;
        }
        
        if (el.kind == XlKindDict) {
            NSDictionary<NSString *, CrossType *> * xlDictRef = (NSDictionary<NSString *, CrossType *> *)el.rawValue;
            if (xlDictRef.count == 0) {
                [r appendString:@"{}"];
                continue;
            }
            
            NSUInteger childT = curT + 1;
            
            JsonSfyTok * tokCls = [[JsonSfyTok alloc] init];
            tokCls.t = @"raw";
            tokCls.rv = p ? 
                [NSString stringWithFormat:@"\n%@}", stringRepeat(t, curT)] : @" }";
            tokCls.d = curT;
            [s addObject:tokCls];
            
            NSArray<NSString *> * allKeys = [xlDictRef allKeys];
            
            for (NSInteger i = (NSInteger)allKeys.count - 1; i >= 0; i -= 1) {
                NSString * key = allKeys[i];
                CrossType * val = [xlDictRef objectForKey:key];
                
                JsonSfyTok * tokDi = [[JsonSfyTok alloc] init];
                tokDi.t = @"ref";
                tokDi.v = val;
                tokDi.d = childT;
                [s addObject:tokDi];
                
                JsonSfyTok * tokDk = [[JsonSfyTok alloc] init];
                tokDk.t = @"raw";
                tokDk.rv = [NSString stringWithFormat:@"\"%@\": ", key];
                tokDk.d = childT;
                [s addObject:tokDk];
                
                if (i > 0) {
                    JsonSfyTok * tokCom = [[JsonSfyTok alloc] init];
                    tokCom.t = @"raw";
                    tokCom.rv = p ? 
                        [NSString stringWithFormat:@",\n%@", stringRepeat(t, childT)] : @", ";
                    tokCom.d = childT;
                    [s addObject:tokCom];
                }
            }
            
            JsonSfyTok * tokOpn = [[JsonSfyTok alloc] init];
            tokOpn.t = @"raw";
            tokOpn.rv = p ?
                [NSString stringWithFormat:@"{\n%@", stringRepeat(t, childT)] : @"{ ";
                tokOpn.d = childT;
                [s addObject:tokOpn];
                continue;
        }
        if (el.kind == XlKindClosure) {
            [r appendString:@"\"[object XlClosure]\""];
            continue;
        }
        [r appendString:@"\"[object [Objective C Thing]]\""];
    }
    return [r copy];
}
