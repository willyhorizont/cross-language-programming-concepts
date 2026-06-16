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
        set result [apply $runtime_callback $combined_args]
        
        # JIKA hasil kembalian berupa lambda expression (list dengan 2 elemen utama)
        # KITA BUNGKUS hasil tersebut ke dalam objek Function baru secara otomatis
        if {[llength $result] == 2} {
            # Membuat objek anonim baru menggunakan oo::copy atau pembuatan instans baru
            set new_obj [Function create [oo::object new] {}]
            $new_obj assign $result
            return $new_obj
        }
        
        return $result
    }
}

# 1. Inisialisasi awal
Function create multiply {}
multiply assign {{variadic_arguments} {
    lassign $variadic_arguments a
    # Mengembalikan struktur lambda Tcl standar
    return {{b} {
        lassign $b nilai_b
        return [expr {$nilai_b * 10}]
    }}
    # Di Tcl, nilai $a dari scope luar harus di-passing eksplisit, atau di-hardcode sesuai kebutuhan logika Anda
}}

# FIX 1: Gunakan [...] biasa, JANGAN gunakan expr untuk call object
# Sekarang $multiply_by_two berisi nama objek Function baru
set multiply_by_two [multiply call {2}]

# FIX 2: Sekarang Anda bisa memanggil method .call pada variabel tersebut
puts "multiply_by_two(10): [$multiply_by_two call {10}]"
