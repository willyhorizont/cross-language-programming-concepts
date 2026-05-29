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
        _ =
        sayHello (_:
            builtins.trace "how are you?" null
        );
    in
    _)
    (let
        multiply = (a: (b: a * b));
        multiplyByTwo = (multiply 2);
        _ =
        builtins.trace (multiplyByTwo 10) null;
    in
    _)
]