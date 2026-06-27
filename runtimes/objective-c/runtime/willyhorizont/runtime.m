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
@class JsonStringifyToken;

int64_t toXlInt(CrossType * obj);
double toXlFloat(CrossType * obj);
CrossType * toXlList(NSArray<CrossType *> * args);
CrossType * toXlDict(NSDictionary<NSString *, CrossType *> * dict, ...);
NSString * stringRepeat(NSString * s, NSUInteger n);
NSString * jsonStringify(NSArray *args);

@interface XlClosureVarArgs : NSObject
@property (nonatomic, strong, readonly) NSArray<CrossType *> * varargs;
@property (nonatomic, assign, readonly) NSUInteger index;
- (instancetype)initWithXlClosureVarArgs:(NSArray<CrossType *> *)args;
- (CrossType *)getNextArguments;
@end

typedef CrossType * (^XlClosure)(XlClosureVarArgs * varargs);

@interface XlDictIndexed : NSObject
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> * keys;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, CrossType *> * map;
- (void)insertKey:(NSString *)key value:(CrossType *)value;
@end

@interface CrossType : NSObject
@property (nonatomic, assign, readonly) CrossTypeKind kind;
@property (nonatomic, strong, readonly) id rawValue;
- (instancetype)initWithXlNone;
- (instancetype)initWithXlBool:(BOOL)v;
- (instancetype)initWithXlInt:(int64_t)v;
- (instancetype)initWithXlFloat:(double)v;
- (instancetype)initWithXlString:(NSString *)v;
- (instancetype)initWithXlList:(NSArray<CrossType *> *)v;
- (instancetype)initWithXlDict:(NSDictionary<NSString *, CrossType *> *)v;
- (instancetype)initWithXlDictIndexed:(XlDictIndexed *)v;
- (instancetype)initWithXlClosure:(XlClosure)v;
- (CrossType *)call:(NSArray<CrossType *> *)args;
@end

@interface JsonStringifyToken : NSObject
@property (nonatomic, strong) NSString * type; // @"reference" or @"primitive"
@property (nonatomic, strong) CrossType * crossTypeValue;
@property (nonatomic, strong) NSString * primitiveValue;
@property (nonatomic, assign) NSUInteger indentationLevel;
@end

@implementation XlClosureVarArgs
- (instancetype)initWithXlClosureVarArgs:(NSArray<CrossType *> *)args {
    self = [super init];
    if (self) {
        _varargs = args;
        _index = 0;
    }
    return self;
}
- (CrossType *)getNextArguments {
    if (_index < self.varargs.count) {
        CrossType * arg = self.varargs[_index];
        _index += 1;
        return arg;
    }
    return [[CrossType alloc] initWithXlNone];
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
- (instancetype)initWithXlNone {
    self = [super init];
    if (self) {
        _kind = XlKindNone; _rawValue = [NSNull null];
    }
    return self;
}
- (instancetype)initWithXlBool:(BOOL)v {
    self = [super init];
    if (self) {
        _kind = XlKindBool; _rawValue = @(v);
    }
    return self;
}
- (instancetype)initWithXlInt:(int64_t)v {
    self = [super init];
    if (self) {
        _kind = XlKindInt; _rawValue = @(v);
    }
    return self;
}
- (instancetype)initWithXlFloat:(double)v {
    self = [super init];
    if (self) {
        _kind = XlKindFloat; _rawValue = @(v);
    }
    return self;
}
- (instancetype)initWithXlString:(NSString *)v {
    self = [super init];
    if (self) {
        _kind = XlKindString; _rawValue = [v copy];
    }
    return self;
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
- (instancetype)initWithXlClosure:(XlClosure)v {
    self = [super init];
    if (self) {
        _kind = XlKindClosure; _rawValue = [v copy];
    }
    return self;
}
- (CrossType *)call:(NSArray<CrossType *> *)args {
    if (self.kind == XlKindClosure) {
        XlClosure closureBlock = (XlClosure)self.rawValue;
        XlClosureVarArgs * tracker = [[XlClosureVarArgs alloc] initWithXlClosureVarArgs:args];
        return closureBlock(tracker);
    }
    @throw [NSException exceptionWithName:@"XlRuntimeError" reason:@"Error: Expected XlClosure." userInfo:nil];
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

int64_t toXlInt(CrossType * obj) {
    if (!obj || obj.kind == XlKindNone) {
        @throw [NSException exceptionWithName:@"CrossTypeError" reason:@"Error: Expected XlInt." userInfo:nil];
    }
    if (obj.kind != XlKindInt) {
        @throw [NSException exceptionWithName:@"CrossTypeError" reason:@"Error: Expected XlInt." userInfo:nil];
    }
    return [obj.rawValue longLongValue];
}

double toXlFloat(CrossType * obj) {
    if (!obj || obj.kind == XlKindNone) {
        @throw [NSException exceptionWithName:@"CrossTypeError" reason:@"Error: Expected XlFloat." userInfo:nil];
    }
    if (obj.kind != XlKindFloat) {
        @throw [NSException exceptionWithName:@"CrossTypeError" reason:@"Error: Expected XlFloat." userInfo:nil];
    }
    return [obj.rawValue doubleValue];
}

CrossType * toXlList(NSArray<CrossType *> * args) {
    return [[CrossType alloc] initWithXlList:args];
}

CrossType * toXlDict(NSDictionary<NSString *, CrossType *> * dict, ...) {
    if (!dict) {
        return [[CrossType alloc] initWithXlNone];
    }

    va_list args;
    va_start(args, dict);
    
    NSArray<NSString *> *keysOrder = va_arg(args, NSArray<NSString *> *);
    va_end(args);

    if (keysOrder && [keysOrder isKindOfClass:[NSArray class]]) {
        XlDictIndexed *indexed = [XlDictIndexed new];
        
        for (NSUInteger i = 0; i < keysOrder.count; i += 1) {
            NSString *key = keysOrder[i];
            CrossType *value = [dict objectForKey:key];
            
            if (value) {
                [indexed insertKey:key value:value];
            }
        }
        return [[CrossType alloc] initWithXlDictIndexed:indexed];
    }

    return [[CrossType alloc] initWithXlDict:dict];
}

NSString * stringRepeat(NSString * s, NSUInteger n) {
    return [@"" stringByPaddingToLength:(s.length * n) withString:s startingAtIndex:0];
}

@implementation JsonStringifyToken
@end

NSString * jsonStringify(NSArray *args) {
    if (!args || args.count == 0) {
        return @"";
    }

    CrossType *anything = args[0];

    BOOL isPretty = NO;
    if (args.count > 1) {
        CrossType *optionsParam = args[1];
        if (optionsParam && optionsParam.kind == XlKindDict) {
            NSDictionary<NSString *, CrossType *> *dict = (NSDictionary<NSString *, CrossType *> *)optionsParam.rawValue;
            CrossType *prettyVal = [dict objectForKey:@"pretty"];
            if (prettyVal && prettyVal.kind == XlKindBool) {
                isPretty = [prettyVal.rawValue boolValue];
            }
        }
    }

    NSString * indentation = @"    ";
    NSMutableArray<JsonStringifyToken *> * tokenStack = [[NSMutableArray alloc] init];
    
    JsonStringifyToken * rootToken = [[JsonStringifyToken alloc] init];
    rootToken.type = @"reference";
    rootToken.crossTypeValue = anything;
    rootToken.primitiveValue = @"";
    rootToken.indentationLevel = 0;
    [tokenStack addObject:rootToken];
    
    NSMutableString * result = [[NSMutableString alloc] init];
    
    while (tokenStack.count > 0) {
        JsonStringifyToken * current = tokenStack.lastObject;
        [tokenStack removeLastObject];
        
        if ([current.type isEqualToString:@"primitive"]) {
            [result appendString:current.primitiveValue];
            continue;
        }
        
        NSUInteger currentIndentationLevel = current.indentationLevel;
        CrossType * currentCrossObj = current.crossTypeValue;
        
        if (currentCrossObj.kind == XlKindNone) {
            [result appendString:@"null"];
            continue;
        }
        
        if (currentCrossObj.kind == XlKindString) {
            [result appendFormat:@"\"%@\"", currentCrossObj.rawValue];
            continue;
        }
        
        if (currentCrossObj.kind == XlKindBool) {
            [result appendString:[currentCrossObj.rawValue boolValue] ? @"true" : @"false"];
            continue;
        }
        
        if (currentCrossObj.kind == XlKindInt || currentCrossObj.kind == XlKindFloat) {
            [result appendFormat:@"%@", currentCrossObj.rawValue];
            continue;
        }
        
        if (currentCrossObj.kind == XlKindList) {
            NSArray<CrossType *> * xlListRef = (NSArray<CrossType *> *)currentCrossObj.rawValue;
            if (xlListRef.count == 0) {
                [result appendString:@"[]"];
                continue;
            }
            
            NSUInteger childIndentationLevel = currentIndentationLevel + 1;
            
            JsonStringifyToken * closeToken = [[JsonStringifyToken alloc] init];
            closeToken.type = @"primitive";
            closeToken.primitiveValue = isPretty ? 
                [NSString stringWithFormat:@"\n%@]", stringRepeat(indentation, currentIndentationLevel)] : @"]";
            closeToken.indentationLevel = currentIndentationLevel;
            [tokenStack addObject:closeToken];
            
            for (NSInteger i = (NSInteger)xlListRef.count - 1; i >= 0; i -= 1) {
                JsonStringifyToken * itemToken = [[JsonStringifyToken alloc] init];
                itemToken.type = @"reference";
                itemToken.crossTypeValue = xlListRef[i];
                itemToken.indentationLevel = childIndentationLevel;
                [tokenStack addObject:itemToken];
                
                if (i > 0) {
                    JsonStringifyToken * commaToken = [[JsonStringifyToken alloc] init];
                    commaToken.type = @"primitive";
                    commaToken.primitiveValue = isPretty ? 
                        [NSString stringWithFormat:@",\n%@", stringRepeat(indentation, childIndentationLevel)] : @", ";
                    commaToken.indentationLevel = childIndentationLevel;
                    [tokenStack addObject:commaToken];
                }
            }
            
            JsonStringifyToken * openToken = [[JsonStringifyToken alloc] init];
            openToken.type = @"primitive";
            openToken.primitiveValue = isPretty ? 
                [NSString stringWithFormat:@"[\n%@", stringRepeat(indentation, childIndentationLevel)] : @"[";
            openToken.indentationLevel = childIndentationLevel;
            [tokenStack addObject:openToken];
            continue;
        }
        
        if (currentCrossObj.kind == XlKindDictIndexed) {
            XlDictIndexed * xlDictIndexedRef = (XlDictIndexed *)currentCrossObj.rawValue;
            if (xlDictIndexedRef.keys.count == 0) {
                [result appendString:@"{}"];
                continue;
            }
            
            NSUInteger childIndentationLevel = currentIndentationLevel + 1;
            
            JsonStringifyToken * closeToken = [[JsonStringifyToken alloc] init];
            closeToken.type = @"primitive";
            closeToken.primitiveValue = isPretty ? 
                [NSString stringWithFormat:@"\n%@}", stringRepeat(indentation, currentIndentationLevel)] : @" }";
            closeToken.indentationLevel = currentIndentationLevel;
            [tokenStack addObject:closeToken];
            
            for (NSInteger i = (NSInteger)xlDictIndexedRef.keys.count - 1; i >= 0; i -= 1) {
                NSString * key = xlDictIndexedRef.keys[i];
                CrossType * val = [xlDictIndexedRef.map objectForKey:key];
                
                JsonStringifyToken * valToken = [[JsonStringifyToken alloc] init];
                valToken.type = @"reference";
                valToken.crossTypeValue = val;
                valToken.indentationLevel = childIndentationLevel;
                [tokenStack addObject:valToken];
                
                JsonStringifyToken * keyToken = [[JsonStringifyToken alloc] init];
                keyToken.type = @"primitive";
                keyToken.primitiveValue = [NSString stringWithFormat:@"\"%@\": ", key];
                keyToken.indentationLevel = childIndentationLevel;
                [tokenStack addObject:keyToken];
                
                if (i > 0) {
                    JsonStringifyToken * commaToken = [[JsonStringifyToken alloc] init];
                    commaToken.type = @"primitive";
                    commaToken.primitiveValue = isPretty ? 
                        [NSString stringWithFormat:@",\n%@", stringRepeat(indentation, childIndentationLevel)] : @", ";
                    commaToken.indentationLevel = childIndentationLevel;
                    [tokenStack addObject:commaToken];
                }
            }
            
            JsonStringifyToken * openToken = [[JsonStringifyToken alloc] init];
            openToken.type = @"primitive";
            openToken.primitiveValue = isPretty ? 
                [NSString stringWithFormat:@"{\n%@", stringRepeat(indentation, childIndentationLevel)] : @"{ ";
            openToken.indentationLevel = childIndentationLevel;
            [tokenStack addObject:openToken];
            continue;
        }
        
        if (currentCrossObj.kind == XlKindDict) {
            NSDictionary<NSString *, CrossType *> * xlDictRef = (NSDictionary<NSString *, CrossType *> *)currentCrossObj.rawValue;
            if (xlDictRef.count == 0) {
                [result appendString:@"{}"];
                continue;
            }
            
            NSUInteger childIndentationLevel = currentIndentationLevel + 1;
            
            JsonStringifyToken * closeToken = [[JsonStringifyToken alloc] init];
            closeToken.type = @"primitive";
            closeToken.primitiveValue = isPretty ? 
                [NSString stringWithFormat:@"\n%@}", stringRepeat(indentation, currentIndentationLevel)] : @" }";
            closeToken.indentationLevel = currentIndentationLevel;
            [tokenStack addObject:closeToken];
            
            NSArray<NSString *> * allKeys = [xlDictRef allKeys];
            
            for (NSInteger i = (NSInteger)allKeys.count - 1; i >= 0; i -= 1) {
                NSString * key = allKeys[i];
                CrossType * val = [xlDictRef objectForKey:key];
                
                JsonStringifyToken * valToken = [[JsonStringifyToken alloc] init];
                valToken.type = @"reference";
                valToken.crossTypeValue = val;
                valToken.indentationLevel = childIndentationLevel;
                [tokenStack addObject:valToken];
                
                JsonStringifyToken * keyToken = [[JsonStringifyToken alloc] init];
                keyToken.type = @"primitive";
                keyToken.primitiveValue = [NSString stringWithFormat:@"\"%@\": ", key];
                keyToken.indentationLevel = childIndentationLevel;
                [tokenStack addObject:keyToken];
                
                if (i > 0) {
                    JsonStringifyToken * commaToken = [[JsonStringifyToken alloc] init];
                    commaToken.type = @"primitive";
                    commaToken.primitiveValue = isPretty ? 
                        [NSString stringWithFormat:@",\n%@", stringRepeat(indentation, childIndentationLevel)] : @", ";
                    commaToken.indentationLevel = childIndentationLevel;
                    [tokenStack addObject:commaToken];
                }
            }
            
            JsonStringifyToken * openToken = [[JsonStringifyToken alloc] init];
            openToken.type = @"primitive";
            openToken.primitiveValue = isPretty ?
                [NSString stringWithFormat:@"{\n%@", stringRepeat(indentation, childIndentationLevel)] : @"{ ";
                openToken.indentationLevel = childIndentationLevel;
                [tokenStack addObject:openToken];
                continue;
        }
        if (currentCrossObj.kind == XlKindClosure) {
            [result appendString:@"\"XlClosure\""];
            continue;
        }
        [result appendString:@"\"Unknown\""];
    }
    return [result copy];
}
