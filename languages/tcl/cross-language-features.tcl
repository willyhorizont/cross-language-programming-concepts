oo::class create Function {
    variable runtime_callback
    variable factor

    constructor {callback_or_factor args} {
        if {[llength $args] > 0} {
            set factor [list $callback_or_factor]
            set runtime_callback [lindex $args 0]
        } else {
            set factor {}
            set runtime_callback $callback_or_factor
        }
    }

    method call {args} {
        set combined_args [list {*}$args {*}$factor]
        set result [apply $runtime_callback $combined_args]
        return $result
    }
}

# 1. support closure as value, or has workaround
set greet_and_do_something [Function new {{variadic_arguments} {
    lassign $variadic_arguments callback_function
    puts "hello"
    apply $callback_function
}}]
$greet_and_do_something call {{} {
    puts "wold"
}}
set multiply [Function new {{variadic_arguments} {
    lassign $variadic_arguments a
    return [Function new $a {{variadic_arguments_inner} {
        lassign $variadic_arguments_inner b b_factor
        return [expr {$b * $b_factor}]
    }}]
}}]
set multiply_by_two [$multiply call 2]
puts "multiply_by_two(10): [$multiply_by_two call 10]"
set multiply_by_eight [$multiply call 8]
puts "multiply_by_eight(4): [$multiply_by_eight call 4]"
puts "multiply_by_two(8): [$multiply_by_two call 8]"
set get_rectangle_area [Function new {{variadic_arguments} {
    lassign $variadic_arguments a b
    return [expr {$a * $b}]
}}]
puts "get_rectangle_area(7, 5): [$get_rectangle_area call 7 5]"
set get_block_volume [Function new {{variadic_arguments} {
    lassign $variadic_arguments a b c
    return [expr {$a * $b * $c}]
}}]
puts "get_block_volume(7, 5, 4): [$get_block_volume call 7 5 4]"

# 2. support dynamic-typed value, or has workaround
set empty_python_like_list {}
lappend empty_python_like_list ""
lappend empty_python_like_list true
lappend empty_python_like_list false
lappend empty_python_like_list "foo"
lappend empty_python_like_list 0
lappend empty_python_like_list -123
lappend empty_python_like_list 123.789
lappend empty_python_like_list -123.789
lappend empty_python_like_list {1 2 3}
lappend empty_python_like_list [dict create foo "bar"]
lappend empty_python_like_list {[Function new {{variadic_arguments} {
    lassign $variadic_arguments a b
    return [expr {$a * $b}]
}}]}
set some_python_like_list $empty_python_like_list
puts "some_python_like_list: $some_python_like_list"
set empty_python_like_dict [dict create]
dict set empty_python_like_dict some_null ""
dict set empty_python_like_dict some_boolean_true true
dict set empty_python_like_dict some_boolean_false false
dict set empty_python_like_dict some_string "foo"
dict set empty_python_like_dict some_int_positive 0
dict set empty_python_like_dict some_int_negative -123
dict set empty_python_like_dict some_float_positive 123.789
dict set empty_python_like_dict some_float_negative -123.789
dict set empty_python_like_dict some_python_like_list {1 2 3}
dict set empty_python_like_dict some_python_like_dict [dict create foo "bar"]
dict set empty_python_like_dict some_python_like_function {[Function new {{variadic_arguments} {
    lassign $variadic_arguments a b
    return [expr {$a * $b}]
}}]}
set some_python_like_dict $empty_python_like_dict
puts "some_python_like_dict: $some_python_like_dict"
