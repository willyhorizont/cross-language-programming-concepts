oo::class create Function {
    variable factor
    variable runtime_callback
    
    constructor {variadic_arguments} {
        set factor $variadic_arguments
        set runtime_callback ""
    }
    
    # Method tambahan untuk memasukkan data baru ke dalam objek
    method set_factor {new_factor} {
        set factor $new_factor
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
Function create multiply {}
multiply assign {{variadic_arguments} {
    lassign $variadic_arguments a
    
    # 1. Buat objek baru secara anonim
    set new_obj [Function new {}]
    
    # 2. Simpan nilai 'a' langsung ke dalam properti objek baru tersebut
    $new_obj set_factor $a
    
    # 3. Definisikan lambda secara normal, TANPA subst, TANPA backslash (\)
    $new_obj assign {{variadic_arguments_inner} {
        lassign $variadic_arguments_inner b b_factor
        # b_factor adalah nilai 'a' yang tadi kita simpan via set_factor
        return [expr {$b * $b_factor}]
    }}
    
    return $new_obj
}}

# Eksekusi kode berjalan dengan rapi
set multiply_by_two [multiply call {2}]
puts "multiply_by_two(10): [$multiply_by_two call {10}]"
# Output: multiply_by_two(10): 20
set multiply_by_eight [multiply call {8}]
puts "multiply_by_eight(4): [$multiply_by_eight call {4}]"
puts "multiply_by_two(8): [$multiply_by_two call {8}]"
