Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "..", "runtimes", "wolfram-language-mathematica", "willyhorizont", "runtime", "xl.wl"}]];

(*
1. support lambda as value, or has workaround
*)
SayHello = {CallbackFunction} |-> (
    Print["hello"];
    CallbackFunction[]
);
SayHello[{} |-> (
    Print["world"]
)];
CreateMultiplier = {Aa} |-> {Bb} |-> Aa * Bb;
MultiplyByTwo = CreateMultiplier[2];
Print["multiply_by_two(10): ", MultiplyByTwo[10]];
MultiplyByEight = CreateMultiplier[8];
Print["multiply_by_eight(4): ", MultiplyByEight[4]];
Print["multiply_by_two(8): ", MultiplyByTwo[8]];

(*
2. support dynamic-typed value, or has workaround
*)
XlList = {
    Null,
    True,
    False,
    "foo",
    0,
    123,
    123.789,
    -123.789,
    {1, 2, 3},
    <|"foo" -> "bar"|>,
    ({Aa, Bb} |-> Aa * Bb)
};
Print["xl_list: ", Xl`JsonStringify[{XlList}]];
Print["xl_list: ", Xl`JsonStringify[{XlList, "Pretty" -> True}]];
XlDict = <|
    "xl_none" -> Null,
    "xl_bool_true" -> True,
    "xl_bool_false" -> False,
    "xl_string" -> "foo",
    "xl_int_positive" -> 0,
    "xl_int_negative" -> 123,
    "xl_float_positive" -> 123.789,
    "xl_float_negative" -> -123.789,
    "xl_list" -> {1, 2, 3},
    "xl_dict" -> <|"foo" -> "bar"|>,
    "xl_lambda" -> ({Aa, Bb} |-> Aa * Bb)
|>;
Print["xl_dict: ", Xl`JsonStringify[{XlDict}]];
Print["xl_dict: ", Xl`JsonStringify[{XlDict, "Pretty" -> True}]];
