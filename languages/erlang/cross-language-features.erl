-module(main).
-export([main/0]).

main() ->
    %% 1. support closure as value, or has workaround
    SayHello = fun(CallbackFunction) ->
        io:fwrite("hello~n"),
        CallbackFunction()
    end,

    SayHello(fun() ->
        io:fwrite("world~n")
    end),

    CreateMultiplier = fun(Aa) -> 
        fun(Bb) -> (Aa * Bb) end 
    end,

    MultiplyByTwo = CreateMultiplier(2),
    io:fwrite("multiply_by_two.(10): ~p~n", [MultiplyByTwo(10)]),

    MultiplyByEight = CreateMultiplier(8),
    io:fwrite("multiply_by_eight.(4): ~p~n", [MultiplyByEight(4)]),
    io:fwrite("multiply_by_two.(8): ~p~n", [MultiplyByTwo(8)]),

    %% 2. support dynamic-typed value, or has workaround
    SomePythonLikeList = [
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
    io:fwrite("some_python_like_list: ~p~n", [SomePythonLikeList]),

    SomePythonLikeDict = #{
        <<"some_null">> => nil,
        <<"some_boolean_true">> => true,
        <<"some_boolean_false">> => false,
        <<"some_string">> => <<"foo">>,
        <<"some_int_positive">> => 0,
        <<"some_int_negative">> => -123,
        <<"some_float_positive">> => 123.789,
        <<"some_float_negative">> => -123.789,
        <<"some_python_like_list">> => [1, 2, 3],
        <<"some_python_like_dict">> => #{<<"foo">> => <<"bar">>},
        <<"some_function">> => fun(Aa, Bb) -> (Aa * Bb) end
    },
    io:fwrite("some_python_like_dict: ~p~n", [SomePythonLikeDict]).
