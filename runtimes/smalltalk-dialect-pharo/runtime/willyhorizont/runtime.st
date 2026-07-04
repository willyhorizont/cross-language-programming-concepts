Smalltalk at: #WillyHorizontRuntime put: Dictionary new.

(Smalltalk at: #WillyHorizontRuntime) at: #iter put: [ :a |
    Generator on: [ :gen |
        a do: [ :each |
            gen yield: each.
        ].
    ].
].

(Smalltalk at: #WillyHorizontRuntime) at: #getType put: [ :a |
    a ifNil: [ '[object XlNone]' ] ifNotNil: [
        (a isKindOf: BlockClosure) ifTrue: [ '[object XlClosure]' ] ifFalse: [
            ((a isKindOf: OrderedDictionary) or: (a isKindOf: Dictionary)) ifTrue: [ '[object XlDict]' ] ifFalse: [
                (a isArray or: [ a isCollection and: [ a isString not ] ]) ifTrue: [ '[object XlList]' ] ifFalse: [
                    a isString ifTrue: [ '[object XlString]' ] ifFalse: [
                        (a isKindOf: Boolean) ifTrue: [ '[object XlBool]' ] ifFalse: [
                            a isInteger ifTrue: [ '[object XlInt]' ] ifFalse: [
                                a isFloat ifTrue: [ '[object XlFloat]' ] ifFalse: [
                                    a printString
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    ]
].

(Smalltalk at: #WillyHorizontRuntime) at: #jsonStringify put: [ :va |
    | xl itr a opt p t s r c v curD curT childD dL dK dV |
    xl := Smalltalk at: #WillyHorizontRuntime.
    ((xl at: #getType) value: va) = '[object XlList]' ifTrue: [
        itr := (xl at: #iter) value: va.
        a := itr next.
        a ifNil: [
            a := va.
        ] ifNotNil: [
            opt := itr next.
            opt ifNil: [
                p := false.
            ] ifNotNil: [
                p := opt at: 'pretty'.
            ].
        ].
    ] ifFalse: [
        a := va.
        p := false.
    ].
    t := '    '.
    s := OrderedCollection new.
    s add: (Dictionary new
        at: 't' put: 'v';
        at: 'v' put: a;
        at: 'd' put: 0;
    yourself).
    r := ''.
    [ s isEmpty ] whileFalse: [
        c := s removeLast.
        (c at: 't') = 'r' ifTrue: [
            r := r , (c at: 'v').
        ] ifFalse: [
            v := c at: 'v'.
            curT := (xl at: #getType) value: v.
            curD := c at: 'd'.
            curT = '[object XlNone]' ifTrue: [ r := r , 'null' ].
            curT = '[object XlBool]' ifTrue: [ r := r , (v ifTrue: ['true'] ifFalse: ['false']) ].
            curT = '[object XlString]' ifTrue: [ r := r , '"' , v asString , '"' ].
            (curT = '[object XlInt]' or: [ curT = '[object XlFloat]' ]) ifTrue: [ r := r , v asString ].
            curT = '[object XlList]' ifTrue: [
                v isEmpty ifTrue: [
                    r := r , '[]'
                ] ifFalse: [
                    childD := curD + 1.
                    s add: (Dictionary new
                        at: 't' put: 'r';
                        at: 'v' put: (p ifTrue: [ String lf , (t repeat: curD) , ']' ] ifFalse: [ ']' ]);
                        at: 'd' put: curD;
                        yourself).
                    v size to: 1 by: -1 do: [ :i |
                        s add: (Dictionary new
                            at: 't' put: 'v';
                            at: 'v' put: (v at: i);
                            at: 'd' put: childD;
                            yourself).

                        i > 1 ifTrue: [
                            s add: (Dictionary new
                                at: 't' put: 'r';
                                at: 'v' put: (p ifTrue: [ ',' , String lf , (t repeat: childD) ] ifFalse: [ ', ' ]);
                                at: 'd' put: childD;
                                yourself).
                        ].
                    ].
                    s add: (Dictionary new
                        at: 't' put: 'r';
                        at: 'v' put: (p ifTrue: [ '[' , String lf , (t repeat: childD) ] ifFalse: [ '[' ]);
                        at: 'd' put: childD;
                        yourself).
                ].
            ].
            curT = '[object XlDict]' ifTrue: [
                v isEmpty ifTrue: [
                    r := r , '{}'
                ] ifFalse: [
                    childD := curD + 1.
                    dL := v associations asArray.
                    s add: (Dictionary new
                        at: 't' put: 'r';
                        at: 'v' put: (p ifTrue: [ String lf , (t repeat: curD) , '}' ] ifFalse: [ ' }' ]);
                        at: 'd' put: curD;
                        yourself).
                    dL size to: 1 by: -1 do: [ :i |
                        dK := (dL at: i) key.
                        dV := (dL at: i) value.
                        s add: (Dictionary new
                            at: 't' put: 'v';
                            at: 'v' put: dV;
                            at: 'd' put: childD;
                            yourself).
                        s add: (Dictionary new
                            at: 't' put: 'r';
                            at: 'v' put: '"' , dK asString , '": ';
                            at: 'd' put: childD;
                            yourself).
                        i > 1 ifTrue: [
                            s add: (Dictionary new
                                at: 't' put: 'r';
                                at: 'v' put: (p ifTrue: [ ',' , String lf , (t repeat: childD) ] ifFalse: [ ', ' ]);
                                at: 'd' put: childD;
                                yourself).
                        ].
                    ].
                    s add: (Dictionary new
                        at: 't' put: 'r';
                        at: 'v' put: (p ifTrue: [ '{' , String lf , (t repeat: childD) ] ifFalse: [ '{ ' ]);
                        at: 'd' put: childD;
                        yourself).
                ].
            ].
            curT = '[object XlClosure]' ifTrue: [
                r := r , '"' , '[object Function]' , '"'
            ].
            ((curT = '[object XlNone]' or: [ curT = '[object XlBool]' or: [ curT = '[object XlString]' or: [ curT = '[object XlInt]' or: [ curT = '[object XlFloat]' or: [ curT = '[object XlList]' or: [ curT = '[object XlDict]' or: [ curT = '[object XlClosure]' ] ] ] ] ] ] ])) ifFalse: [
                r := r , '"[object ["Smalltalk \"' , curT , '\"]"'.
            ].
        ].
    ].
    r.
].
