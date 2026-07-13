Smalltalk at: #WillyHorizont put: Dictionary new.
(Smalltalk at: #WillyHorizont) at: #Runtime put: Dictionary new.

((Smalltalk at: #WillyHorizont) at: #Runtime) at: #escapeString put: [ :aString |
    String streamContents: [ :s |
        | backslash doubleQuote |
        backslash := Character value: 92.
        doubleQuote := Character value: 34.
        aString do: [ :c |
            c = backslash ifTrue: [ s nextPutAll: '\\' ] ifFalse: [
            c = doubleQuote ifTrue: [ s nextPutAll: '\"' ] ifFalse: [
            c = Character lf ifTrue: [ s nextPutAll: '\n' ] ifFalse: [
            c = Character cr ifTrue: [ s nextPutAll: '\r' ] ifFalse: [
            c = Character tab ifTrue: [ s nextPutAll: '\t' ] ifFalse: [
                s nextPut: c ] ] ] ] ] ] ] ].

((Smalltalk at: #WillyHorizont) at: #Runtime) at: #stringRepeat put: [ :str :count |
    String streamContents: [ :stream |
        count timesRepeat: [ stream nextPutAll: str ] ] ].

((Smalltalk at: #WillyHorizont) at: #Runtime) at: #iter put: [ :a |
    Generator on: [ :gen |
        a do: [ :each |
            gen yield: each.
        ].
    ].
].

((Smalltalk at: #WillyHorizont) at: #Runtime) at: #getType put: [ :a |
    a ifNil: [ '[object XlNone]' ] ifNotNil: [
        (a isKindOf: BlockClosure) ifTrue: [ '[object XlClosure]' ] ifFalse: [
            ((a isKindOf: OrderedDictionary) or: [ a isKindOf: Dictionary ]) ifTrue: [ '[object XlDict]' ] ifFalse: [
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

((Smalltalk at: #WillyHorizont) at: #Runtime) at: #jsonStringify put: [ :va |
    | xl itr a opt p t s r c v curT curD childD dL dK dV |
    xl := (Smalltalk at: #WillyHorizont) at: #Runtime.
    ((xl at: #getType) value: va) = '[object XlList]' ifTrue: [
        itr := (xl at: #iter) value: va.
        a := itr next.
        a ifNil: [
            a := va.
            p := false.
        ] ifNotNil: [
            opt := itr next.
            opt ifNil: [
                p := false.
            ] ifNotNil: [
                p := opt at: 'pretty' ifAbsent: [ false ].
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
            curT = '[object XlString]' ifTrue: [ r := r , '"' , ((xl at: #escapeString) value: v) , '"' ].
            (curT = '[object XlInt]' or: [ curT = '[object XlFloat]' ]) ifTrue: [ r := r , v asString ].
            curT = '[object XlList]' ifTrue: [
                v isEmpty ifTrue: [
                    r := r , '[]'
                ] ifFalse: [
                    childD := curD + 1.
                    s add: (Dictionary new
                        at: 't' put: 'r';
                        at: 'v' put: (p ifTrue: [ String lf , ((xl at: #stringRepeat) value: t value: curD) , ']' ] ifFalse: [ ']' ]);
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
                                at: 'v' put: (p ifTrue: [ ',' , String lf , ((xl at: #stringRepeat) value: t value: childD) ] ifFalse: [ ', ' ]);
                                at: 'd' put: childD;
                            yourself).
                        ].
                    ].
                    s add: (Dictionary new
                        at: 't' put: 'r';
                        at: 'v' put: (p ifTrue: [ '[' , String lf , ((xl at: #stringRepeat) value: t value: childD) ] ifFalse: [ '[' ]);
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
                        at: 'v' put: (p ifTrue: [ String lf , ((xl at: #stringRepeat) value: t value: curD) , '}' ] ifFalse: [ '}' ]);
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
                                at: 'v' put: (p ifTrue: [ ',' , String lf , ((xl at: #stringRepeat) value: t value: childD) ] ifFalse: [ ', ' ]);
                                at: 'd' put: childD;
                            yourself).
                        ].
                    ].
                    s add: (Dictionary new
                        at: 't' put: 'r';
                        at: 'v' put: (p ifTrue: [ '{' , String lf , ((xl at: #stringRepeat) value: t value: childD) ] ifFalse: [ '{' ]);
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
