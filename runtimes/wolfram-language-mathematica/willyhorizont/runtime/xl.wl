BeginPackage["Xl`"];

EscapeString::usage = "EscapeString[{S}]";
JsonStringify::usage = "JsonStringify[{A, \"pretty\" -> True}] or JsonStringify[{A}]";

Begin["`Private`"];

EscapeString[{S_}] := (
    If[S === Null, (
        Return[""]
    )];
    R = ToString[S];
    R = StringReplace[R, "\\" -> "\\\\"];
    R = StringReplace[R, "\"" -> "\\\""];
    R = StringReplace[R, "\n" -> "\\n"];
    R = StringReplace[R, "\r" -> "\\r"];
    R = StringReplace[R, "\t" -> "\\t"];
    R
);

JsonStringify[{A_, O___}] := Module[
    {P, T, R, S, C, CurT, V, CurD, ChildD, Dpl, Dk, Dv, Llen, DplLen, J}, (
        P = Lookup[Association[{O}], "Pretty", False];
        T = StringRepeat[" ", 4];
        R = "";
        S = {Association["t" -> "v", "v" -> A, "d" -> 0]};
        While[Length[S] > 0, (
            C = Last[S];
            S = Most[S];
            CurT = C["t"];
            V = C["v"];
            CurD = C["d"];
            If[CurT === "r", (
                R = R <> ToString[V];
                Continue[]
            )];
            If[V === Null, (
                R = R <> "null";
                Continue[]
            )];
            If[MatchQ[V, True | False], (
                R = R <> If[V === True, "true", "false"];
                Continue[]
            )];
            If[Head[V] === String, (
                R = R <> "\"" <> EscapeString[{V}] <> "\"";
                Continue[]
            )];
            If[MatchQ[V, _Integer | _Real], (
                R = R <> ToString[V];
                Continue[]
            )];
            If[ToString[Head[V]] === "Function" || StringContainsQ[ToString[Head[V]], "Function"] || MatchQ[V, _Function], (
                R = R <> "\"[object Function]\"";
                Continue[]
            )];
            If[Head[V] === List, (
                Llen = Length[V];
                If[Llen === 0, (
                    R = R <> "[]";
                    Continue[]
                )];
                ChildD = CurD + 1;
                AppendTo[S, Association[
                    "t" -> "r",
                    "v" -> If[P === True, "\n" <> StringRepeat[T, CurD] <> "]", "]"],
                    "d" -> CurD
                ]];
                Do[(
                    AppendTo[S, Association[
                        "t" -> "v",
                        "v" -> V[[J]],
                        "d" -> ChildD
                    ]];
                    If[J > 1, (
                        AppendTo[S, Association[
                            "t" -> "r",
                            "v" -> If[P === True, ",\n" <> StringRepeat[T, ChildD], ","],
                            "d" -> ChildD
                        ]]
                    )];
                ), {J, Llen, 1, -1}];
                R = R <> If[P === True, "[\n" <> StringRepeat[T, ChildD], "["];
                Continue[]
            )];
            If[Head[V] === Association, (
                Dpl = KeyValueMap[{K, V} |-> {K, V}, V];
                DplLen = Length[Dpl];
                    If[DplLen === 0, (
                        R = R <> "{}";
                        Continue[]
                    )];
                    ChildD = CurD + 1;
                    AppendTo[S, Association[
                        "t" -> "r",
                        "v" -> If[P === True, "\n" <> StringRepeat[T, CurD] <> "}", "}"],
                        "d" -> CurD
                    ]];
                    Do[(
                        Dk = ToString[Dpl[[J, 1]]];
                        Dv = Dpl[[J, 2]];
                        AppendTo[S, Association[
                            "t" -> "v",
                            "v" -> Dv,
                            "d" -> ChildD
                        ]];
                        AppendTo[S, Association[
                            "t" -> "r",
                            "v" -> If[P === True, "\"" <> Dk <> "\": ", "\"" <> Dk <> "\":"],
                            "d" -> ChildD
                        ]];
                        If[J > 1, (
                            AppendTo[S, Association[
                                "t" -> "r",
                                "v" -> If[P === True, ",\n" <> StringRepeat[T, ChildD], ","],
                                "d" -> ChildD
                            ]]
                        )];
                    ), {J, DplLen, 1, -1}];
                    R = R <> If[P === True, "{\n" <> StringRepeat[T, ChildD], "{"];
                    Continue[]
            )];
            R = R <> "\"" <> ToString[Head[V]] <> "\"";
        )];
        R
    )
];

End[];
EndPackage[];
