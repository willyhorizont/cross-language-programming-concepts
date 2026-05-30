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
set empty_python_like_list {}
lappend empty_python_like_list ""
lappend empty_python_like_list true
lappend empty_python_like_list false
lappend empty_python_like_list "foo"
lappend empty_python_like_list 123
lappend empty_python_like_list -123
lappend empty_python_like_list 123.789
lappend empty_python_like_list -123.789
lappend empty_python_like_list {1 2 3}
lappend empty_python_like_list [dict create foo "bar"]
lappend empty_python_like_list {{variadic_arguments} {
    lassign $variadic_arguments a b
    return [expr {$a * $b}] 
}}
set some_python_like_list $empty_python_like_list
puts "some_python_like_list: $some_python_like_list"
set empty_python_like_dict [dict create]
dict set empty_python_like_dict some_null ""
dict set empty_python_like_dict some_boolean_true true
dict set empty_python_like_dict some_boolean_false false
dict set empty_python_like_dict some_string "foo"
dict set empty_python_like_dict some_int_positive 123
dict set empty_python_like_dict some_int_negative -123
dict set empty_python_like_dict some_float_positive 123.789
dict set empty_python_like_dict some_float_negative -123.789
dict set empty_python_like_dict some_python_like_list {1 2 3}
dict set empty_python_like_dict some_python_like_dict [dict create foo "bar"]
dict set empty_python_like_dict some_python_like_function {{variadic_arguments} {
    lassign $variadic_arguments a b
    return [expr {$a * $b}] 
}}
set some_python_like_dict $empty_python_like_dict
puts "some_python_like_dict: $some_python_like_dict"
