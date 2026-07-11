let
    runtime = import ../../runtimes/nix/willyhorizont/runtime.nix { };
in
runtime.do [
    /*
    1. support closure as value, or has workaround
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
                builtins.trace "world"
                state
            )
    )

    (state:
        let
            createMultiplier = (a: (b: a * b));
        in
            state // {
                createMultiplier = createMultiplier;
            }
    )

    (state:
        let
            multiplyByTwo = (state.createMultiplier 2);
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
            multiplyByEight = (state.createMultiplier 8);
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

    /*
    2. support dynamic-typed value, or has workaround
    */
    (state:
        let
            xlList = [
                null
                true
                false
                "foo"
                0
                (-123)
                123.789
                (-123.789)
                [ 1 2 3 ]
                { "foo" = "bar"; }
                (a: (b: a * b))
            ];
        in
            state // {
                xlList = xlList;
            }
    )

    (state:
        let
        in
            builtins.trace (builtins.deepSeq state.xlList state.xlList)
            state
    )

    (state:
        let
            xlDict = {
                "xl_null" = null;
                "xl_boolean_true" = true;
                "xl_boolean_false" = false;
                "xl_string" = "foo";
                "xl_int_positive" = 0;
                "xl_int_negative" = (-123);
                "xl_float_positive" = 123.789;
                "xl_float_negative" = (-123.789);
                "xl_list" = [ 1 2 3 ];
                "xl_dict" = { "foo" = "bar"; };
                "xl_closure" = (a: (b: a * b));
            };
        in
            state // {
                xlDict = xlDict;
            }
    )

    (state:
        let
        in
            builtins.trace (builtins.deepSeq state.xlDict state.xlDict)
            state
    )
]
