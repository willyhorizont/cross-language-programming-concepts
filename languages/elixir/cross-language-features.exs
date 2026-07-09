# 1. support closure as value, or has workaround
say_hello = fn (callback_function) ->
    "hello" |> IO.puts()
    callback_function.()
end
say_hello.(fn () ->
    "world" |> IO.puts()
end)
create_multiplier = fn (aa) -> (fn (bb) -> (aa * bb) end) end
multiply_by_two = create_multiplier.(2)
"multiply_by_two.(10): #{10 |> multiply_by_two.()}" |> IO.puts()
multiply_by_eight = create_multiplier.(8)
"multiply_by_eight.(4): #{4 |> multiply_by_eight.()}" |> IO.puts()
"multiply_by_two.(8): #{8 |> multiply_by_two.()}" |> IO.puts()

# 2. support dynamic-typed value, or has workaround
some_python_like_list = [
    nil,
    true,
    false,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    %{ "foo" => "bar" },
    fn (aa, bb) -> (aa * bb) end,
]
"some_python_like_list: #{some_python_like_list |> inspect()}" |> IO.puts()
some_python_like_dict = %{
    "some_null" => nil,
    "some_boolean_true" => true,
    "some_boolean_false" => false,
    "some_string" => "foo",
    "some_int_positive" => 0,
    "some_int_negative" => -123,
    "some_float_positive" => 123.789,
    "some_float_negative" => -123.789,
    "some_python_like_list" => [1, 2, 3],
    "some_python_like_dict" => %{ "foo" => "bar" },
    "some_function" => fn (aa, bb) -> (aa * bb) end,
}
"some_python_like_dict: #{some_python_like_dict |> inspect()}" |> IO.puts()
