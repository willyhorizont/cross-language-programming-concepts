include("../../runtimes/julia/willyhorizont/runtime/xl.jl")

#=
1. support lambda as value, or has workaround
=#
say_hello = (callback_function) -> begin
    println("hello")
    callback_function()
end
say_hello(() -> begin
    println("world")
end)
create_multiplier = aa -> bb -> aa * bb
multiply_by_two = create_multiplier(2)
println("multiply_by_two(10): $(multiply_by_two(10))")
multiply_by_eight = create_multiplier(8)
println("multiply_by_eight(4): $(multiply_by_eight(4))")
println("multiply_by_two(8): $(multiply_by_two(8))")

#=
2. support dynamic-typed value, or has workaround
=#
xl_list = [
    nothing,
    true,
    false,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    Dict("foo" => "bar"),
    (aa, bb) -> aa * bb,
]
println("xl_list: $(Xl.json_stringify(xl_list))")
println("xl_list: $(Xl.json_stringify(xl_list, pretty=true))")
xl_dict = Dict(
    "xl_none" => nothing,
    "xl_bool_true" => true,
    "xl_bool_false" => false,
    "xl_string" => "foo",
    "xl_int_positive" => 0,
    "xl_int_negative" => -123,
    "xl_float_positive" => 123.789,
    "xl_float_negative" => -123.789,
    "xl_list" => [1, 2, 3],
    "xl_dict" => Dict("foo" => "bar"),
    "xl_lambda" => (aa, bb) -> aa * bb,
)
println("xl_dict: $(Xl.json_stringify(xl_dict))")
println("xl_dict: $(Xl.json_stringify(xl_dict, pretty=true))")
