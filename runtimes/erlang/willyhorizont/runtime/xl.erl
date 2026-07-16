-module(xl).
-export([escape_string/1, json_stringify/1, json_stringify/2]).

escape_string(S) when is_binary(S) ->
    escape_string(S, <<>>).

escape_string(<<>>, Acc) ->
    Acc;
escape_string(<<$\\, Rest/binary>>, Acc) ->
    escape_string(Rest, <<Acc/binary, "\\\\">>);
escape_string(<<$", Rest/binary>>, Acc) ->
    escape_string(Rest, <<Acc/binary, "\\\"">>);
escape_string(<<$\n, Rest/binary>>, Acc) ->
    escape_string(Rest, <<Acc/binary, "\\n">>);
escape_string(<<$\r, Rest/binary>>, Acc) ->
    escape_string(Rest, <<Acc/binary, "\\r">>);
escape_string(<<$\t, Rest/binary>>, Acc) ->
    escape_string(Rest, <<Acc/binary, "\\t">>);
escape_string(<<C, Rest/binary>>, Acc) ->
    escape_string(Rest, <<Acc/binary, C>>).

jify_list([], _, _, _, Acc) ->
    Acc;

jify_list([Head | Tail], ChildD, P, T, Acc) ->
    AccLel = [#{
        <<"t">> => <<"v">>,
        <<"v">> => Head,
        <<"d">> => ChildD
    } | Acc],
    jify_list(Tail, ChildD, P, T, (case Tail of
        [] ->
            AccLel;
        _ ->
            [#{
                <<"t">> => <<"r">>,
                <<"v">> => (if
                    P -> <<",\n", (binary:copy(T, ChildD))/binary>>;
                    true -> <<",">>
                end),
                <<"d">> => ChildD
            } | AccLel]
    end)).

jify_dict([], _, _, _, Acc) ->
    Acc;

jify_dict([{Dk, Dv} | Tail], ChildD, P, T, Acc) ->
    AccDel = [#{
        <<"t">> => <<"r">>,
        <<"v">> => (if
            P -> <<"\"", Dk/binary, "\": ">>;
            true -> <<"\"", Dk/binary, "\":">>
        end),
        <<"d">> => ChildD
    },
    #{
        <<"t">> => <<"v">>,
        <<"v">> => Dv,
        <<"d">> => ChildD
    } | Acc],
    jify_dict(Tail, ChildD, P, T, (case Tail of
        [] ->
            AccDel;
        _ ->
            [#{
                <<"t">> => <<"r">>,
                <<"v">> => (if
                    P -> <<",\n", (binary:copy(T, ChildD))/binary>>;
                    true -> <<",">>
                end),
                <<"d">> => ChildD
            } | AccDel]
    end)).

jify_loop([], R, _, _) ->
    R;

jify_loop([C | NS], R, P, T) ->
    Ct = maps:get(<<"t">>, C),
    if
        Ct =:= <<"r">> ->
            CV = maps:get(<<"v">>, C),
            jify_loop(NS, <<R/binary, CV/binary>>, P, T);
        true ->
            V = maps:get(<<"v">>, C),
            CurD = maps:get(<<"d">>, C),
            if
                V =:= nil ->
                    jify_loop(NS, <<R/binary, "null">>, P, T);
                V =:= true ->
                    jify_loop(NS, <<R/binary, "true">>, P, T);
                V =:= false ->
                    jify_loop(NS, <<R/binary, "false">>, P, T);
                is_binary(V) ->
                    jify_loop(NS, <<R/binary, "\"", (escape_string(V))/binary, "\"">>, P, T);
                is_integer(V) ->
                    jify_loop(NS, <<R/binary, (integer_to_binary(V))/binary>>, P, T);
                is_float(V) ->
                    jify_loop(NS, <<R/binary, (float_to_binary(V, [{decimals, 4}, compact]))/binary>>, P, T);
                is_function(V) ->
                    jify_loop(NS, <<R/binary, "\"[object Function]\"">>, P, T);
                is_list(V) ->
                    if
                        V =:= [] ->
                            jify_loop(NS, <<R/binary, "[]">>, P, T);
                        true ->
                            ChildD = CurD + 1,
                            jify_loop([#{
                                <<"t">> => <<"r">>,
                                <<"v">> => (if
                                    P -> <<"[\n", (binary:copy(T, ChildD))/binary>>;
                                    true -> <<"[">>
                                end),
                                <<"d">> => ChildD
                            } | jify_list(lists:reverse(V), ChildD, P, T, [#{
                                <<"t">> => <<"r">>,
                                <<"v">> => (if
                                    P -> <<"\n", (binary:copy(T, CurD))/binary, "]">>;
                                    true -> <<"]">>
                                end),
                                <<"d">> => CurD
                            } | NS])], R, P, T)
                    end;
                is_map(V) ->
                    DPL = maps:to_list(V),
                    if
                        DPL =:= [] ->
                            jify_loop(NS, <<R/binary, "{}">>, P, T);
                        true ->
                            ChildD = CurD + 1,
                            jify_loop([#{
                                <<"t">> => <<"r">>,
                                <<"v">> => (if
                                    P -> <<"{\n", (binary:copy(T, ChildD))/binary>>;
                                    true -> <<"{">>
                                end),
                                <<"d">> => ChildD
                            } | jify_dict(lists:reverse(DPL), ChildD, P, T, [#{
                                <<"t">> => <<"r">>,
                                <<"v">> => (if
                                    P -> <<"\n", (binary:copy(T, CurD))/binary, "}">>;
                                    true -> <<"}">>
                                end),
                                <<"d">> => CurD
                            } | NS])], R, P, T)
                    end;
                true ->
                    jify_loop(NS, <<R/binary, "\"[object Object]\"">>, P, T)
            end
    end.

json_stringify(A) ->
    json_stringify(A, []).

json_stringify(A, O) ->
    P = proplists:get_value(pretty, O, false),
    T = binary:copy(<<" ">>, 4),
    S = [#{<<"t">> => <<"v">>, <<"v">> => A, <<"d">> => 0}],
    R = <<"">>,
    jify_loop(S, R, P, T).
