let
    do = _: builtins.deepSeq _ _;
in
do [
    /*
    1. support function as value
    */
    (let
        var = {
            "_" = null;
        };
        _ = var // {
            sayHello = (callbackFunction:
                builtins.trace "hello"
                (callbackFunction null));
            _ =
            _.sayHello (_:
                builtins.trace "how are you?" null
            );
            multiply = (a: (b: a * b));
            multiplyByTwo = (_.multiply 2);
            x =
            builtins.trace (_.multiplyByTwo 10) null;
        };
    in
    _)
]