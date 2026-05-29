let
    do = _: builtins.deepSeq _ _;
in
do [
    /*
    1. support function as value
    */
    (let
        var = [ ];
        _ = var ++ [
            sayHello = (callbackFunction:
                builtins.trace "hello"
                (callbackFunction null));
            sayHello (_:
                builtins.trace "how are you?" null
            );
            multiply = (a: (b: a * b));
            multiplyByTwo = (multiply 2);
            builtins.trace (multiplyByTwo 10) null;
        ];
    in
    _)
]