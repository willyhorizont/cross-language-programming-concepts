oo::class create Function {
    variable factor
    variable runtime_callback
    
    constructor {variadic_arguments} {
        # Analogi (variadic_arguments) => undefined (kosong jika tidak diisi)
        set factor $variadic_arguments
        set runtime_callback ""
    }
    
    # Method assign untuk mendaftarkan logika utama Anda
    method assign {callback_function} {
        set runtime_callback $callback_function
        return ""
    }
    
    # Method call untuk mengeksekusi dan melempar argumen baru (seperti fungsi runtime)
    method call {new_argument} {
        # Gabungkan argumen baru dengan data awal (factor) untuk disuapkan ke runtime_callback
        set combined_args [list $new_argument {*}$factor]
        return [apply $runtime_callback $combined_args]
    }
}

# 1. Inisialisasi kosong (Analogi JS: variadic_arguments => undefined)
Function create greet_and_do_something {}

# 2. Definisikan alur logika utama (Menerima input argumen dari metode 'call')
greet_and_do_something assign {{variadic_arguments} {
    lassign $variadic_arguments callback_function
    puts "hello"
    apply $callback_function
}}

# 3. Eksekusi fungsi dengan mengirimkan lambda "wold" (world) secara dinamis
greet_and_do_something call {{} {
    puts "world"
}}

Function create multiply {}
multiply assign {{variadic_arguments} {
    lassign $variadic_arguments a
    Function create multiply_by {}
    multiply_by assign {{variadic_arguments_inner} {
        lassign $variadic_arguments b
        return [expr {$a * $b}]
    }}
    return {multiply_by}
}}
set multiply_by_two [multiply call {2}]
puts "multiply_by_two(10): [multiply_by_two call {10}]"
