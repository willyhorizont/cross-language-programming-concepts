-module(main).
-export([start/0]).
-define(xl, willyhorizont_runtime).

start() ->
    %% 1. support closure as value, or has workaround
    SayHello = fun(CallbackFunction) ->
        io:format("hello~n"),
        CallbackFunction()
    end,
    SayHello(fun() ->
        io:format("world~n")
    end),
    CreateMultiplier = fun(Aa) ->
        fun(Bb) -> (Aa * Bb) end
    end,
    MultiplyByTwo = CreateMultiplier(2),
    io:format("multiply_by_two(10): ~p~n", [MultiplyByTwo(10)]),
    MultiplyByEight = CreateMultiplier(8),
    io:format("multiply_by_eight(4): ~p~n", [MultiplyByEight(4)]),
    io:format("multiply_by_two(8): ~p~n", [MultiplyByTwo(8)]),

    %% 2. support dynamic-typed value, or has workaround
    XlList = [
        nil,
        true,
        false,
        <<"foo">>,
        0,
        -123,
        123.789,
        -123.789,
        [1, 2, 3],
        #{<<"foo">> => <<"bar">>},
        fun(Aa, Bb) -> (Aa * Bb) end
    ],
    io:format("xl_list: ~s~n", [?xl:json_stringify(XlList)]),
    io:format("xl_list: ~s~n", [?xl:json_stringify(XlList, [{pretty, true}])]),
    XlDict = #{
        <<"xl_none">> => nil,
        <<"xl_bool_true">> => true,
        <<"xl_bool_false">> => false,
        <<"xl_string">> => <<"foo">>,
        <<"xl_int_positive">> => 0,
        <<"xl_int_negative">> => -123,
        <<"xl_float_positive">> => 123.789,
        <<"xl_float_negative">> => -123.789,
        <<"xl_list">> => [1, 2, 3],
        <<"xl_dict">> => #{<<"foo">> => <<"bar">>},
        <<"xl_closure">> => fun(Aa, Bb) -> (Aa * Bb) end
    },
    io:format("xl_dict: ~s~n", [?xl:json_stringify(XlDict)]),
    io:format("xl_dict: ~s~n", [?xl:json_stringify(XlDict, [{pretty, true}])]).
