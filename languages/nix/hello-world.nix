let
    do = _: builtins.deepSeq _ _;
in
do [
    (let
    in
        builtins.trace "hello, world" null
    )
]