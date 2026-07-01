| xl |
xl := Smalltalk at: #WillyHorizontRuntime.

"
1. support closure as value, or has workaround
"
Smalltalk at: #sayHello put: [ :callbackFunction |
    Stdio stdout nextPutAll: 'hello'; lf.
    callbackFunction value.
].
(Smalltalk at: #sayHello) value: [
    Stdio stdout nextPutAll: 'world'; lf
].
Smalltalk at: #createMultiplier put: [ :aa | [ :bb | aa * bb ] ].
Smalltalk at: #multiplyByTwo put: ((Smalltalk at: #createMultiplier) value: 2).
Stdio stdout nextPutAll: 'multiply_by_two(10): ', ((Smalltalk at: #multiplyByTwo) value: 10) asString; lf.
Smalltalk at: #multiplyByEight put: ((Smalltalk at: #createMultiplier) value: 8).
Stdio stdout nextPutAll: 'multiply_by_eight(4): ', ((Smalltalk at: #multiplyByEight) value: 4) asString; lf.
Stdio stdout nextPutAll: 'multiply_by_two(8): ', ((Smalltalk at: #multiplyByTwo) value: 8) asString; lf.

"
2. support dynamic-typed value, or has workaround
"
Smalltalk at: #xlList put: (
    OrderedCollection new
        add: nil;
        add: true;
        add: false;
        add: 'foo';
        add: 0;
        add: -123;
        add: 123.789;
        add: -123.789;
        add: (OrderedCollection new add: 1; add: 2; add: 3; yourself) asArray;
        add: (Dictionary new at: 'foo' put: 'bar'; yourself);
        add: [ :aa :bb | aa * bb ];
    yourself
) asArray.
Stdio stdout nextPutAll: 'xl_list:'; lf; nextPutAll: ((xl at: #jsonStringify) value: (OrderedCollection new add: (Smalltalk at: #xlList); yourself) asArray); lf.
Stdio stdout nextPutAll: 'xl_list:'; lf; nextPutAll: ((xl at: #jsonStringify) value: (OrderedCollection new add: (Smalltalk at: #xlList); add: (Dictionary new at: 'pretty' put: true; yourself); yourself) asArray); lf.
Smalltalk at: #xlDict put: (
    Dictionary new
        at: 'xl_none' put: nil;
        at: 'xl_bool_true' put: true;
        at: 'xl_bool_false' put: false;
        at: 'xl_string' put: 'foo';
        at: 'xl_int_positive' put: 0;
        at: 'xl_int_negative' put: -123;
        at: 'xl_float_positive' put: 123.789;
        at: 'xl_float_negative' put: -123.789;
        at: 'xl_list' put: (OrderedCollection new add: 1; add: 2; add: 3; yourself) asArray;
        at: 'xl_dict' put: (Dictionary new at: 'foo' put: 'bar'; yourself);
        at: 'xl_closure' put: [ :aa :bb | aa * bb ];
    yourself
).
Stdio stdout nextPutAll: 'xl_dict:'; lf; nextPutAll: ((xl at: #jsonStringify) value: (OrderedCollection new add: (Smalltalk at: #xlDict); yourself) asArray); lf.
Stdio stdout nextPutAll: 'xl_dict:'; lf; nextPutAll: ((xl at: #jsonStringify) value: (OrderedCollection new add: (Smalltalk at: #xlDict); add: (Dictionary new at: 'pretty' put: true; yourself); yourself) asArray); lf.
Smalltalk at: #xlDictIndexed put: (
    OrderedDictionary new
        at: 'xl_none' put: nil;
        at: 'xl_bool_true' put: true;
        at: 'xl_bool_false' put: false;
        at: 'xl_string' put: 'foo';
        at: 'xl_int_positive' put: 0;
        at: 'xl_int_negative' put: -123;
        at: 'xl_float_positive' put: 123.789;
        at: 'xl_float_negative' put: -123.789;
        at: 'xl_list' put: (OrderedCollection new add: 1; add: 2; add: 3; yourself) asArray;
        at: 'xl_dict' put: (Dictionary new at: 'foo' put: 'bar'; yourself);
        at: 'xl_closure' put: [ :aa :bb | aa * bb ];
    yourself
).
Stdio stdout nextPutAll: 'xl_dict_indexed:'; lf; nextPutAll: ((xl at: #jsonStringify) value: (OrderedCollection new add: (Smalltalk at: #xlDictIndexed); yourself) asArray); lf.
Stdio stdout nextPutAll: 'xl_dict_indexed:'; lf; nextPutAll: ((xl at: #jsonStringify) value: (OrderedCollection new add: (Smalltalk at: #xlDictIndexed); add: (Dictionary new at: 'pretty' put: true; yourself); yourself) asArray); lf.
