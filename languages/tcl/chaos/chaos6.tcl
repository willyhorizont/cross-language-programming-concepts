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

    method call {new_argument} {
        set combined_args [list $new_argument {*}$factor]
        set result [apply $runtime_callback $combined_args]
        return $result
    }
}

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

set multiply_by_two [$multiply call {2}]
puts "multiply_by_two(10): [$multiply_by_two call {10}]"

set multiply_by_eight [$multiply call {8}]
puts "multiply_by_eight(4): [$multiply_by_eight call {4}]"

puts "multiply_by_two(8): [$multiply_by_two call {8}]"
