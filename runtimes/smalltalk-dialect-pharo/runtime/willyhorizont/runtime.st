Smalltalk at: #WillyHorizontRuntime put: Dictionary new.

(Smalltalk at: #WillyHorizontRuntime) at: #iter put: [ :a |
    Generator on: [ :gen |
        a do: [ :each |
            gen yield: each.
        ].
    ].
].

(Smalltalk at: #WillyHorizontRuntime) at: #getType put: [ :a |
    a ifNil: [ 'XlNone' ] ifNotNil: [
        (a isKindOf: BlockClosure) ifTrue: [ 'XlClosure' ] ifFalse: [
            ((a isKindOf: OrderedDictionary) or: (a isKindOf: Dictionary)) ifTrue: [ 'XlDict' ] ifFalse: [
                (a isArray or: [ a isCollection and: [ a isString not ] ]) ifTrue: [ 'XlList' ] ifFalse: [
                    a isString ifTrue: [ 'XlString' ] ifFalse: [
                        (a isKindOf: Boolean) ifTrue: [ 'XlBool' ] ifFalse: [
                            a isInteger ifTrue: [ 'XlInt' ] ifFalse: [
                                a isFloat ifTrue: [ 'XlFloat' ] ifFalse: [
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
    | xl itr a opt p t s r c cT cV curD curVt childD dpL k v |

    xl := Smalltalk at: #WillyHorizontRuntime.

    ((xl at: #getType) value: va) = 'XlList' ifTrue: [
        itr := (xl at: #iter) value: va.

        a := itr next.
        a ifNil: [
            a := va.
        ] ifNotNil: [
            opt := itr next.
            opt ifNil: [
                p := false.
            ] ifNotNil: [
                p := opt at: 'p'.
            ].
        ].
    ] ifFalse: [
        a := va.
        p := false.
    ].
    t := '    '.
    r := ''.

    s := OrderedCollection new.
    s add: (Dictionary new
        at: 't' put: 'v';
        at: 'v' put: a;
        at: 'd' put: 0;
        yourself).

    [ s isEmpty ] whileFalse: [
        c := s removeLast.
        cT := c at: 't'.
        cV := c at: 'v'.
        curD := c at: 'd'.

        cT = 'r' ifTrue: [
            r := r , cV.
        ] ifFalse: [
            curVt := (xl at: #getType) value: cV.

            curVt = 'XlNone' ifTrue: [ r := r , 'null' ].
            curVt = 'XlBool' ifTrue: [ r := r , (cV ifTrue: ['true'] ifFalse: ['false']) ].
            curVt = 'XlString' ifTrue: [ r := r , '"' , cV asString , '"' ].
            (curVt = 'XlInt' or: [ curVt = 'XlFloat' ]) ifTrue: [ r := r , cV asString ].

            curVt = 'XlList' ifTrue: [
                cV isEmpty ifTrue: [
                    r := r , '[]'
                ] ifFalse: [
                    childD := curD + 1.

                    s add: (Dictionary new
                        at: 't' put: 'r';
                        at: 'v' put: (p ifTrue: [ String lf , (t repeat: curD) , ']' ] ifFalse: [ ']' ]);
                        at: 'd' put: curD;
                        yourself).

                    cV size to: 1 by: -1 do: [ :i |
                        s add: (Dictionary new
                            at: 't' put: 'v';
                            at: 'v' put: (cV at: i);
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

            curVt = 'XlDict' ifTrue: [
                cV isEmpty ifTrue: [
                    r := r , '{}'
                ] ifFalse: [
                    childD := curD + 1.
                    dpL := cV associations asArray.

                    s add: (Dictionary new
                        at: 't' put: 'r';
                        at: 'v' put: (p ifTrue: [ String lf , (t repeat: curD) , '}' ] ifFalse: [ ' }' ]);
                        at: 'd' put: curD;
                        yourself).

                    dpL size to: 1 by: -1 do: [ :i |
                        k := (dpL at: i) key.
                        v := (dpL at: i) value.

                        s add: (Dictionary new
                            at: 't' put: 'v';
                            at: 'v' put: v;
                            at: 'd' put: childD;
                            yourself).

                        s add: (Dictionary new
                            at: 't' put: 'r';
                            at: 'v' put: '"' , k asString , '": ';
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

            curVt = 'XlClosure' ifTrue: [
                r := r , '"' , '[object Function]' , '"'
            ].

            ((curVt = 'XlNone' or: [ curVt = 'XlBool' or: [ curVt = 'XlString' or: [ curVt = 'XlInt' or: [ curVt = 'XlFloat' or: [ curVt = 'XlList' or: [ curVt = 'XlDict' or: [ curVt = 'XlClosure' ] ] ] ] ] ] ])) ifFalse: [
                r := r , '"' , curVt , '"'.
            ].
        ].
    ].
    r.
].
