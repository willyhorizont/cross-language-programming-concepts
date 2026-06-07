multiply_aa = fn (a, b) ->
    (a * b)
end
"multiply_aa.(7, 5): #{multiply_aa.(7, 5)}" |> IO.puts()

multiply_bb = fn (a, b) -> (a * b) end
"multiply_bb.(7, 5): #{multiply_bb.(7, 5)}" |> IO.puts()

multiply_cc = &(&1 * &2)
"multiply_cc.(7, 5): #{multiply_cc.(7, 5)}" |> IO.puts()
