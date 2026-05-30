# puts [namespace children ::]
# namespace delete ::closure1
# puts [namespace children ::]

# puts [namespace children ::]
# set closureNamespace [lindex $multiplyByTwo 2]
# namespace delete $closureNamespace
# puts [namespace children ::]

puts [namespace children ::]
set destroy_closure {{closure} {
    if {[llength $closure] >= 3} {
        namespace delete [lindex $closure 2]
    }
}}
apply $destroy_closure $multiplyByTwo
apply $destroy_closure $multiplyByTen
puts [namespace children ::]