oo::class create Function {
    variable factor
    variable runtime_callback
    
    constructor {variadic_arguments} {
        set factor $variadic_arguments
        set runtime_callback ""
    }
    
    method assign {callback_function} {
        set runtime_callback $callback_function
        return ""
    }
    
    method call {new_argument} {
        set combined_args [list $new_argument {*}$factor]
        return [apply $runtime_callback $combined_args]
    }
}

Function create greet_and_do_something {}
greet_and_do_something assign {{variadic_arguments} {
    lassign $variadic_arguments callback_function
    puts "hello"
    apply $callback_function
}}
greet_and_do_something call {{} {
    puts "wold"
}}

# Inisialisasi objek utama
set multiply [Function new {}]
$multiply assign {{variadic_arguments} {
    lassign $variadic_arguments a

    set new_obj [Function new {}]

    $new_obj assign [list {variadic_arguments_inner} [subst {
        lassign \$variadic_arguments_inner b
        return \[expr {$a * \$b}\]
    }]]

    return $new_obj
}}

# Kode eksekusi sekarang berjalan 100% mulus
set multiply_by_two [$multiply call {2}]
puts "multiply_by_two(10): [$multiply_by_two call {10}]"
# Output: multiply_by_two(10): 20
set multiply_by_eight [$multiply call {8}]
puts "multiply_by_eight(4): [$multiply_by_eight call {4}]"
puts "multiply_by_two(8): [$multiply_by_two call {8}]"
