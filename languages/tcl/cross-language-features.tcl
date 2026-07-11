source [file join [file dirname [file normalize [info script]]] ".." ".." "runtimes" "tcl" "willyhorizont" "runtime" "runtime.tcl"]

# 1. support closure as value, or has workaround
set say_hello [xl::closure {{va} {
    lassign $va callback_function
    puts "hello"
    $callback_function call
}}]
$say_hello call [list [xl::closure {{va} {
    puts "world"
}}]]
set create_multiplier [xl::closure {{va} {
    lassign $va aa
    return [xl::closure $aa {{va} {
        lassign $va aa bb
        return [expr {$aa * $bb}]
    }}]
}}]
set multiply_by_two [$create_multiplier call [list 2]]
puts "multiply_by_two(10): [$multiply_by_two call [list 10]]"
set multiply_by_eight [$create_multiplier call [list 8]]
puts "multiply_by_eight(4): [$multiply_by_eight call [list 4]]"
puts "multiply_by_two(8): [$multiply_by_two call [list 8]]"

# 2. support dynamic-typed value, or has workaround
set xl_list [list \
    "" \
    true \
    false \
    "foo" \
    0 \
    -123 \
    123.789 \
    -123.789 \
    [list 1 2 3] \
    [dict create "foo" "bar"] \
    [xl::closure {{va} {
        lassign $va aa bb
        return [expr {$aa * $bb}]
    }}] \
]
puts "xl_list: [xl::json_stringify $xl_list]"
puts "xl_list: [xl::json_stringify $xl_list [dict create "pretty" true]]"
set xl_dict [dict create \
    "xl_none" "" \
    "xl_bool_true" true \
    "xl_bool_false" false \
    "xl_string" "foo" \
    "xl_int_positive" 0 \
    "xl_int_negative" -123 \
    "xl_float_positive" 123.789 \
    "xl_float_negative" -123.789 \
    "xl_list" [list 1 2 3] \
    "xl_dict" [dict create foo "bar"] \
    "xl_closure" [xl::closure {{va} {
        lassign $va aa bb
        return [expr {$aa * $bb}]
    }}] \
]
puts "xl_dict: [xl::json_stringify $xl_dict]"
puts "xl_dict: [xl::json_stringify $xl_dict [dict create "pretty" true]]"
