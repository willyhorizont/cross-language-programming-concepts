{ ... }:

let
    do = varArgs:
        builtins.foldl'
            (acc: v:
            let
                r = v acc;
            in
                builtins.deepSeq r r
            )
            { }
            varArgs;
in
{
    inherit do;
}
