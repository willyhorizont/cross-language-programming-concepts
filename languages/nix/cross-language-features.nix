let
    do = _: builtins.deepSeq _ _;
in
do [
    /*
    1. support function as value
    */
    (let
        sayHello = (callbackFunction:
            builtins.trace "hello"
            (callbackFunction null));
    in
        sayHello (_:
            builtins.trace "wold" null
        )
    )
    (let
        multiply = (a: (b: a * b));
        multiplyByTwo = (multiply 2);
    in
        builtins.trace (multiplyByTwo 10) null
    )

    /*
    2. support dynamic-typed value, or has workaround
    */
    (let
        somePythonLikeList = [
            null
            true
            false
            "foo"
            123
            (-123)
            123.789
            (-123.789)
            [ 1 2 3 ]
            { "foo" = "bar"; }
            (a: (b: a * b))
        ];
    in
        builtins.trace (builtins.deepSeq somePythonLikeList somePythonLikeList) null
        # builtins.trace (builtins.toJSON somePythonLikeList) null # error if contain function
    )
    (let
        somePythonLikeDict = {
            "some_null" = null;
            "some_boolean_true" = true;
            "some_boolean_false" = false;
            "some_string" = "foo";
            "some_int_positive" = 123;
            "some_int_negative" = (-123);
            "some_float_positive" = 123.789;
            "some_float_negative" = (-123.789);
            "some_python_like_list" = [ 1 2 3 ];
            "some_python_like_dict" = { "foo" = "bar"; };
            "some_function" = (a: (b: a * b));
        };
    in
        builtins.trace (builtins.deepSeq somePythonLikeDict somePythonLikeDict) null
        # builtins.trace (builtins.toJSON somePythonLikeDict) null # error if contain function
    )
]