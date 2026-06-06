let
    do = variadicArguments:
        builtins.foldl'
        (accumulator: currentValue:
        let
            result = currentValue accumulator;
        in
            builtins.deepSeq result result
        )
        { }
        variadicArguments;
in
do [
    /*
    1. support function as value
    */
    (state:
    let
        sayHello = (callbackFunction:
        builtins.trace "hello"
        (callbackFunction null)
        );
    in
        state // {
        sayHello = sayHello;
        }
    )

    (state:
    let
    in
        state.sayHello (_:
        builtins.trace "wold"
        state
        )
    )

    (state:
    let
        multiply = (a: (b: a * b));
    in
        state // {
        multiply = multiply;
        }
    )

    (state:
    let
        multiplyByTwo = (state.multiply 2);
    in
        state // {
        multiplyByTwo = multiplyByTwo;
        }
    )

    (state:
    let
    in
        builtins.trace "multiplyByTwo 10: ${toString (state.multiplyByTwo 10)}"
        state
    )

    (state:
    let
        multiplyByEight = (state.multiply 8);
    in
        state // {
        multiplyByEight = multiplyByEight;
        }
    )

    (state:
    let
    in
        builtins.trace "multiplyByEight 4: ${toString (state.multiplyByEight 4)}"
        state
    )

    (state:
    let
    in
        builtins.trace "multiplyByTwo 8: ${toString (state.multiplyByTwo 8)}"
        state
    )

    (state:
    let
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
        state // {
        somePythonLikeList = somePythonLikeList;
        }
    )

    (state:
    let
    in
        builtins.trace (builtins.deepSeq state.somePythonLikeList state.somePythonLikeList)
        state
    )

    (state:
    let
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
        state // {
        somePythonLikeDict = somePythonLikeDict;
        }
    )

    (state:
    let
    in
        builtins.trace (builtins.deepSeq state.somePythonLikeDict state.somePythonLikeDict)
        state
    )
]
