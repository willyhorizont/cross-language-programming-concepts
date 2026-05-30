set closureId 0

set say_hello {{callback_function} {
    puts "hello"
    apply $callback_function
}}
apply $say_hello {{} {
    puts "how are you?"
}}
oo::class create Closure {
    variable factor
    constructor {a} {
        set factor $a
    }
    method pipe {callback_function} {
        return [apply $callback_function $factor]
    }
}
Closure create multiplyByTwo 2
puts "multiplyByTwo(10): [multiplyByTwo pipe {{a} {
    return [expr {$a * 10}] 
}}]"
Closure create multiplyByEight 8
puts "multiplyByEight(4): [multiplyByEight pipe {{a} {
    return [expr {$a * 4}] 
}}]"
puts "multiplyByTwo(8): [multiplyByTwo pipe {{a} {
    return [expr {$a * 8}] 
}}]"
