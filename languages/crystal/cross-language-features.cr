require "../../runtimes/crystal/willyhorizont/runtime/xl"

# 1. support init_lambda as value, or has workaround
say_hello = Xl.init_lambda(->(va : Xl::Type::List) do
    itr = Xl.iter(va)
    callback_function = Xl.next(itr)
    puts "hello"
    Xl.call(callback_function)
end)
Xl.call(say_hello, Xl.init_lambda(->(va : Xl::Type::List) do
    puts "world"
end))
create_multiplier = Xl.init_lambda(->(va : Xl::Type::List) do
    itr = Xl.iter(va)
    aa = Xl.next(itr)
    return Xl.init(Xl.init_lambda(->(va : Xl::Type::List) do
        itr = Xl.iter(va)
        bb = Xl.next(itr)
        return Xl.init(Xl.to_int(aa) * Xl.to_int(bb))
    end))
end)
multiply_by_two = Xl.call(create_multiplier, 2)
puts "multiply_by_two(10): #{Xl.call(multiply_by_two, 10)}"
multiply_by_eight = Xl.call(create_multiplier, 8)
puts "multiply_by_eight(4): #{Xl.call(multiply_by_eight, 4)}"
puts "multiply_by_two(8): #{Xl.call(multiply_by_two, 8)}"

# 2. support dynamic-typed value, or has workaround
xl_list = Xl.init_list(
    nil,
    true,
    false,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    Xl.init_list(1, 2, 3),
    Xl.init_dict({"foo" => "bar"}),
    Xl.init_lambda(->(va : Xl::Type::List) do
        itr = Xl.iter(va)
        aa = Xl.next(itr)
        bb = Xl.next(itr)
        return Xl.init(Xl.to_int(aa) * Xl.to_int(bb))
    end),
)
puts "xl_list: #{Xl.json_stringify(xl_list)}"
puts "xl_list: #{Xl.json_stringify(xl_list, pretty: true)}"
xl_dict = Xl.init_dict({
    "xl_none" => nil,
    "xl_bool_true" => true,
    "xl_bool_false" => false,
    "xl_string" => "foo",
    "xl_int_positive" => 0,
    "xl_int_negative" => -123,
    "xl_float_positive" => 123.789,
    "xl_float_negative" => -123.789,
    "xl_list" => Xl.init_list(1, 2, 3),
    "xl_dict" => Xl.init_dict({"foo" => "bar"}),
    "xl_lambda" => Xl.init_lambda(->(va : Xl::Type::List) do
        itr = Xl.iter(va)
        aa = Xl.next(itr)
        bb = Xl.next(itr)
        return Xl.init(Xl.to_int(aa) * Xl.to_int(bb))
    end),
})
puts "xl_dict: #{Xl.json_stringify(xl_dict)}"
puts "xl_dict: #{Xl.json_stringify(xl_dict, pretty: true)}"
