require_relative "../../runtimes/ruby/willyhorizont/runtime/xl"

=begin
1. support closure as value, or has workaround
=end
say_hello = lambda do | callback_function |
    puts("hello")
    callback_function.call()
end
say_hello.call(lambda do | |
    puts("world")
end)
create_multiplier = lambda do | aa | lambda do | bb | aa * bb end end
multiply_by_two = create_multiplier.call(2)
puts("multiply_by_two(10): #{multiply_by_two.call(10)}")
multiply_by_eight = create_multiplier.call(8)
puts("multiply_by_eight(4): #{multiply_by_eight.call(4)}")
puts("multiply_by_two(8): #{multiply_by_two.call(8)}")

=begin
2. support dynamic-typed value, or has workaround
=end
xl_list = [
    nil,
    true,
    false,
    "foo",
    0,
    123,
    123.789,
    -123.789,
    [1, 2, 3],
    { "foo" => "bar" },
    lambda do | aa, bb | aa * bb end,
]
puts("xl_list: #{Xl.json_stringify(xl_list)}")
puts("xl_list: #{Xl.json_stringify(xl_list, pretty: true)}")
xl_dict = {
    "xl_none" => nil,
    "xl_bool_true" => true,
    "xl_bool_false" => false,
    "xl_string" => "foo",
    "xl_int_positive" => 0,
    "xl_int_negative" => 123,
    "xl_float_positive" => 123.789,
    "xl_float_negative" => -123.789,
    "xl_list" => [1, 2, 3],
    "xl_dict" => { "foo" => "bar" },
    "xl_closure" => lambda do | aa, bb | aa * bb end,
}
puts("xl_dict: #{Xl.json_stringify(xl_dict)}")
puts("xl_dict: #{Xl.json_stringify(xl_dict, pretty: true)}")
