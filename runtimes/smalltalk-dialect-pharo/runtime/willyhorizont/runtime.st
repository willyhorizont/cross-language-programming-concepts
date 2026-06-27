Smalltalk at: #WillyHorizontRuntime put: Dictionary new.

(Smalltalk at: #WillyHorizontRuntime) at: #createXlListIterator put: [ :anyXlList |
    Generator on: [ :gen |
        anyXlList do: [ :each |
            gen yield: each.
        ].
    ].
].

(Smalltalk at: #WillyHorizontRuntime) at: #getType put: [ :anything |
    anything ifNil: [ 'XlNone' ] ifNotNil: [
        (anything isKindOf: BlockClosure) ifTrue: [ 'XlClosure' ] ifFalse: [
            ((anything isKindOf: OrderedDictionary) or: (anything isKindOf: Dictionary)) ifTrue: [ 'XlDict' ] ifFalse: [
                (anything isArray or: [ anything isCollection and: [ anything isString not ] ]) ifTrue: [ 'XlList' ] ifFalse: [
                    anything isString ifTrue: [ 'XlString' ] ifFalse: [
                        (anything isKindOf: Boolean) ifTrue: [ 'XlBool' ] ifFalse: [
                            anything isInteger ifTrue: [ 'XlInt' ] ifFalse: [
                                anything isFloat ifTrue: [ 'XlFloat' ] ifFalse: [
                                    anything printString
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    ]
].

(Smalltalk at: #WillyHorizontRuntime) at: #jsonStringify put: [ :variadicArguments |
    | xl argumentGenerator anything jsonStringifyOption pretty indentation tokenStack result current currentType currentValue currentIndentationLevel currentValueType childIndentationLevel xlDictItems xlDictKey xlDictValue |

    xl := Smalltalk at: #WillyHorizontRuntime.

    ((xl at: #getType) value: variadicArguments) = 'XlList' ifTrue: [
        argumentGenerator := (xl at: #createXlListIterator) value: variadicArguments.

        anything := argumentGenerator next.
        anything ifNil: [
            anything := variadicArguments.
        ] ifNotNil: [
            jsonStringifyOption := argumentGenerator next.
            jsonStringifyOption ifNil: [
                pretty := false.
            ] ifNotNil: [
                pretty := jsonStringifyOption at: 'pretty'.
            ].
        ].
    ] ifFalse: [
        anything := variadicArguments.
        pretty := false.
    ].
    indentation := '    '.
    result := ''.

    tokenStack := OrderedCollection new.
    tokenStack add: (Dictionary new
        at: 'type' put: 'value';
        at: 'value' put: anything;
        at: 'indentationLevel' put: 0;
        yourself).

    [ tokenStack isEmpty ] whileFalse: [
        current := tokenStack removeLast.
        currentType := current at: 'type'.
        currentValue := current at: 'value'.
        currentIndentationLevel := current at: 'indentationLevel'.

        currentType = 'raw' ifTrue: [
            result := result , currentValue.
        ] ifFalse: [
            currentValueType := (xl at: #getType) value: currentValue.

            currentValueType = 'XlNone' ifTrue: [ result := result , 'null' ].
            currentValueType = 'XlBool' ifTrue: [ result := result , (currentValue ifTrue: ['true'] ifFalse: ['false']) ].
            currentValueType = 'XlString' ifTrue: [ result := result , '"' , currentValue asString , '"' ].
            (currentValueType = 'XlInt' or: [ currentValueType = 'XlFloat' ]) ifTrue: [ result := result , currentValue asString ].

            currentValueType = 'XlList' ifTrue: [
                currentValue isEmpty ifTrue: [
                    result := result , '[]'
                ] ifFalse: [
                    childIndentationLevel := currentIndentationLevel + 1.

                    tokenStack add: (Dictionary new
                        at: 'type' put: 'raw';
                        at: 'value' put: (pretty ifTrue: [ String lf , (indentation repeat: currentIndentationLevel) , ']' ] ifFalse: [ ']' ]);
                        at: 'indentationLevel' put: currentIndentationLevel;
                        yourself).

                    currentValue size to: 1 by: -1 do: [ :i |
                        tokenStack add: (Dictionary new
                            at: 'type' put: 'value';
                            at: 'value' put: (currentValue at: i);
                            at: 'indentationLevel' put: childIndentationLevel;
                            yourself).

                        i > 1 ifTrue: [
                            tokenStack add: (Dictionary new
                                at: 'type' put: 'raw';
                                at: 'value' put: (pretty ifTrue: [ ',' , String lf , (indentation repeat: childIndentationLevel) ] ifFalse: [ ', ' ]);
                                at: 'indentationLevel' put: childIndentationLevel;
                                yourself).
                        ].
                    ].

                    tokenStack add: (Dictionary new
                        at: 'type' put: 'raw';
                        at: 'value' put: (pretty ifTrue: [ '[' , String lf , (indentation repeat: childIndentationLevel) ] ifFalse: [ '[' ]);
                        at: 'indentationLevel' put: childIndentationLevel;
                        yourself).
                ].
            ].

            currentValueType = 'XlDict' ifTrue: [
                currentValue isEmpty ifTrue: [
                    result := result , '{}'
                ] ifFalse: [
                    childIndentationLevel := currentIndentationLevel + 1.
                    xlDictItems := currentValue associations asArray.

                    tokenStack add: (Dictionary new
                        at: 'type' put: 'raw';
                        at: 'value' put: (pretty ifTrue: [ String lf , (indentation repeat: currentIndentationLevel) , '}' ] ifFalse: [ ' }' ]);
                        at: 'indentationLevel' put: currentIndentationLevel;
                        yourself).

                    xlDictItems size to: 1 by: -1 do: [ :i |
                        xlDictKey := (xlDictItems at: i) key.
                        xlDictValue := (xlDictItems at: i) value.

                        tokenStack add: (Dictionary new
                            at: 'type' put: 'value';
                            at: 'value' put: xlDictValue;
                            at: 'indentationLevel' put: childIndentationLevel;
                            yourself).

                        tokenStack add: (Dictionary new
                            at: 'type' put: 'raw';
                            at: 'value' put: '"' , xlDictKey asString , '": ';
                            at: 'indentationLevel' put: childIndentationLevel;
                            yourself).

                        i > 1 ifTrue: [
                            tokenStack add: (Dictionary new
                                at: 'type' put: 'raw';
                                at: 'value' put: (pretty ifTrue: [ ',' , String lf , (indentation repeat: childIndentationLevel) ] ifFalse: [ ', ' ]);
                                at: 'indentationLevel' put: childIndentationLevel;
                                yourself).
                        ].
                    ].

                    tokenStack add: (Dictionary new
                        at: 'type' put: 'raw';
                        at: 'value' put: (pretty ifTrue: [ '{' , String lf , (indentation repeat: childIndentationLevel) ] ifFalse: [ '{ ' ]);
                        at: 'indentationLevel' put: childIndentationLevel;
                        yourself).
                ].
            ].

            currentValueType = 'XlClosure' ifTrue: [
                result := result , '"' , '[object Function]' , '"'
            ].

            ((currentValueType = 'XlNone' or: [ currentValueType = 'XlBool' or: [ currentValueType = 'XlString' or: [ currentValueType = 'XlInt' or: [ currentValueType = 'XlFloat' or: [ currentValueType = 'XlList' or: [ currentValueType = 'XlDict' or: [ currentValueType = 'XlClosure' ] ] ] ] ] ] ])) ifFalse: [
                result := result , '"' , currentValueType , '"'.
            ].
        ].
    ].
    result.
].
