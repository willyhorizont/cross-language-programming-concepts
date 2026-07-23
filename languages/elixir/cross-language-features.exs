Code.require_file("../../runtimes/elixir/willyhorizont/runtime/xl.exs", __DIR__)

# 1. support lambda as value, or has workaround
say_hello = fn (callback_function) ->
    "hello" |> IO.puts()
    callback_function.()
end
say_hello.(fn () ->
    "world" |> IO.puts()
end)
create_multiplier = fn (aa) -> (fn (bb) -> aa * bb end) end
multiply_by_two = create_multiplier.(2)
"multiply_by_two.(10): #{10 |> multiply_by_two.()}" |> IO.puts()
multiply_by_eight = create_multiplier.(8)
"multiply_by_eight.(4): #{4 |> multiply_by_eight.()}" |> IO.puts()
"multiply_by_two.(8): #{8 |> multiply_by_two.()}" |> IO.puts()

# 2. support dynamic-typed value, or has workaround
xl_list = [
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
    fn (aa, bb) -> aa * bb end,
]
"xl_list: #{Xl.json_stringify(xl_list)}" |> IO.puts()
"xl_list: #{Xl.json_stringify(xl_list, pretty: true)}" |> IO.puts()
xl_dict = %{
    "xl_none" => nil,
    "xl_bool_true" => true,
    "xl_bool_false" => false,
    "xl_string" => "foo",
    "xl_int_positive" => 0,
    "xl_int_negative" => -123,
    "xl_float_positive" => 123.789,
    "xl_float_negative" => -123.789,
    "xl_list" => [1, 2, 3],
    "xl_dict" => %{ "foo" => "bar" },
    "xl_lambda" => fn (aa, bb) -> aa * bb end,
}
"xl_dict: #{Xl.json_stringify(xl_dict)}" |> IO.puts()
"xl_dict: #{Xl.json_stringify(xl_dict, pretty: true)}" |> IO.puts()
