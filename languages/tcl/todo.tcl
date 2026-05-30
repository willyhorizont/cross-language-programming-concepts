oo::class create Function {
    variable factor
    constructor {variadic_arguments} {
        set factor $variadic_arguments
    }
    method assign {callback_function} {
        return [apply $callback_function $factor]
    }
}

# 1. support function as value
set say_hello {{callback_function} {
    puts "hello"
    apply $callback_function
}}
apply $say_hello {{} {
    puts "wold"
}}
Function create multiplyByTwo {2}
puts "multiplyByTwo(10): [multiplyByTwo assign {{variadic_arguments} {
    lassign $variadic_arguments a
    return [expr {$a * 10}] 
}}]"
Function create multiplyByEight {8}
puts "multiplyByEight(4): [multiplyByEight assign {{variadic_arguments} {
    lassign $variadic_arguments a
    return [expr {$a * 4}] 
}}]"
puts "multiplyByTwo(8): [multiplyByTwo assign {{variadic_arguments} {
    lassign $variadic_arguments a
    return [expr {$a * 8}] 
}}]"
Function create get_rectangle_area {7 5}
puts "get_rectangle_area(7, 5): [get_rectangle_area assign {{variadic_arguments} {
    lassign $variadic_arguments a b
    return [expr {$a * $b}] 
}}]"
Function create get_triangle_area {5 12}
puts "get_triangle_area(5, 12): [get_triangle_area assign {{variadic_arguments} {
    lassign $variadic_arguments a b
    return [expr {0.5 * ($a * $b)}] 
}}]"

# 2. support dynamic-typed value, or has workaround
set some_python_like_list {
    ""
    true
    false
    "foo"
    123
    -123
    123.789
    -123.789
    {1 2 3}
}
lappend some_python_like_list [dict create foo "bar"]
lappend some_python_like_list {{variadic_arguments} {
    lassign $variadic_arguments a b
    return [expr {$a * $b}] 
}}
puts "some_python_like_list: $some_python_like_list"

set some_python_like_dict [dict create \
    some_null "" \
    some_boolean_true true \
    some_boolean_false false \
    some_string "foo" \
    some_int_positive 123 \
    some_int_negative -123 \
    some_float_positive 123.789 \
    some_float_negative -123.789 \
    some_python_like_list {1 2 3} \
    some_python_like_dict [dict create foo "bar"] \
]
dict set some_python_like_dict some_python_like_function {{variadic_arguments} {
    lassign $variadic_arguments a b
    return [expr {$a * $b}] 
}}
puts "some_python_like_dict: $some_python_like_dict"

puts "some_null: [lindex $some_python_like_list 0]"
puts "some_boolean_true: [lindex $some_python_like_list 1]"
puts "some_boolean_false: [lindex $some_python_like_list 2]"
puts "some_string: [lindex $some_python_like_list 3]"
puts "some_int_positive: [lindex $some_python_like_list 4]"
puts "some_int_negative: [lindex $some_python_like_list 5]"
puts "some_float_positive: [lindex $some_python_like_list 6]"
puts "some_float_negative: [lindex $some_python_like_list 7]"
puts "some_python_like_list: [lindex $some_python_like_list 8]"
puts "some_python_like_dict: [lindex $some_python_like_list 9]"
puts "some_python_like_function: [lindex $some_python_like_list 10]"

puts "some_null: [dict get $some_python_like_dict some_null]"
puts "some_boolean_true: [dict get $some_python_like_dict some_boolean_true]"
puts "some_boolean_false: [dict get $some_python_like_dict some_boolean_false]"
puts "some_string: [dict get $some_python_like_dict some_string]"
puts "some_int_positive: [dict get $some_python_like_dict some_int_positive]"
puts "some_int_negative: [dict get $some_python_like_dict some_int_negative]"
puts "some_float_positive: [dict get $some_python_like_dict some_float_positive]"
puts "some_float_negative: [dict get $some_python_like_dict some_float_negative]"
puts "some_python_like_list: [dict get $some_python_like_dict some_python_like_list]"
puts "some_python_like_dict: [dict get $some_python_like_dict some_python_like_dict]"
puts "some_python_like_function: [dict get $some_python_like_dict some_python_like_function]"