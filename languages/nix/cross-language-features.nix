let
    xl = import ../../runtimes/nix/willyhorizont/runtime/xl.nix { };
in
xl.do [
    /*
    1. support lambda as value, or has workaround
    */
    (ctx: ctx // {
    sayHello = (callbackFunction:
        builtins.trace "hello"
        (callbackFunction { })
    );
    })
    (ctx: ctx // {
    _ = ctx.sayHello (_:
        builtins.trace "world"
        { }
    );
    })
    (ctx: ctx // {
    createMultiplier = (aa: (bb: aa * bb));
    })
    (ctx: ctx // {
    multiplyByTwo = (ctx.createMultiplier 2);
    })
    (ctx: ctx // {
    _ = builtins.trace "multiply_by_two(10): ${toString (ctx.multiplyByTwo 10)}" { };
    })
    (ctx: ctx // {
    multiplyByEight = (ctx.createMultiplier 8);
    } )
    (ctx: ctx // {
    _ = builtins.trace "multiply_by_eight(4): ${toString (ctx.multiplyByEight 4)}" { };
    })
    (ctx: ctx // {
    _ = builtins.trace "multiply_by_two(8): ${toString (ctx.multiplyByTwo 8)}" { };
    })

    /*
    2. support dynamic-typed value, or has workaround
    */
    (ctx: ctx // {
    xlList = [
        null
        true
        false
        "foo"
        (0)
        (-123)
        (123.789)
        (-123.789)
        [ 1 2 3 ]
        { "foo" = "bar"; }
        (aa: (bb: aa * bb))
    ];
    })
    (ctx: ctx // {
    _ = builtins.trace "xl_list: ${xl.jsonStringify ctx.xlList { }}" { };
    })
    (ctx: ctx // {
    _ = builtins.trace "xl_list: ${xl.jsonStringify ctx.xlList { pretty = true; }}" { };
    })
    (ctx: ctx // {
    xlDict = {
        "xl_none" = null;
        "xl_bool_true" = true;
        "xl_bool_false" = false;
        "xl_string" = "foo";
        "xl_int_positive" = (0);
        "xl_int_negative" = (-123);
        "xl_float_positive" = (123.789);
        "xl_float_negative" = (-123.789);
        "xl_list" = [ 1 2 3 ];
        "xl_dict" = { "foo" = "bar"; };
        "xl_lambda" = (aa: (bb: aa * bb));
    };
    })
    (ctx: ctx // {
    _ = builtins.trace "xl_dict: ${xl.jsonStringify ctx.xlDict { }}" { };
    })
    (ctx: ctx // {
    _ = builtins.trace "xl_dict: ${xl.jsonStringify ctx.xlDict { pretty = true; }}" { };
    })

    (ctx: { })
]
