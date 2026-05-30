set greet {{name} {
    puts "hello, $name"
}}
apply $greet world

set multiplyByTwo [list x {
    expr {$x * 2}
}]
puts [apply $multiplyByTwo 10]

set multiplyByTwoBb {{x} {
    expr {$x * 2}
}}
puts [apply $multiplyByTwoBb 10]

oo::class create Counter {
    variable count

    constructor {} {
        set count 0
    }

    method inc {} {
        incr count
    }

    method makeGetter {} {
        set captured $count

        return [list {} [list expr $captured]]
    }
}

set c [Counter new]
$c inc
$c inc
$c inc
$c inc
$c inc
$c inc
$c inc

set getCount [$c makeGetter]

puts [apply $getCount]

oo::class create Game {
    variable currentBalance

    constructor {initialBalance} {
        puts "balance: $initialBalance"
        set currentBalance $initialBalance
    }

    method play {} {
        set currentBalance [expr {$currentBalance - 1}]
        if {$currentBalance == 0} {
            puts "not enough balance"
            return
        }
        puts "playing game... $currentBalance balance(s) remaining"
    }
}

Game create playGame 3
playGame play
playGame play
playGame play

oo::class create Multiplier {
    variable factor
    constructor {a} {
        set factor $a
    }
    method create {b} {
        return [expr {$factor * $b}]
    }
}

Multiplier create multiplyBySix 6
puts "multiplyBySix(10): [multiplyBySix create 10]"

Multiplier create multiplyByTwo 2
puts "multiplyByTwo(4): [multiplyByTwo create 4]"
Multiplier create multiplyByEight [multiplyByTwo create 4]
puts "multiplyByEight(10): [multiplyByEight create 10]"

# set multiply {{a} {
#     set namespaceName [namespace current]::closure[incr ::closureId]
#     namespace eval $namespaceName [list variable a $a]
#     return [list {b} {
#         variable a
#         expr {$a * $b}
#     } $namespaceName]
# }}
# set addition {{a} {
#     set namespaceName [namespace current]::closure[incr ::closureId]
#     namespace eval $namespaceName [list variable a $a]
#     return [list {b} {
#         variable a
#         expr {$a + $b}
#     } $namespaceName]
# }}
# 
# set multiplyByTwo [apply $multiply 2]
# puts "multiplyByTwo(10): [apply $multiplyByTwo 10]"
# 
# set multiplyByEight [apply $multiply 8]
# puts "multiplyByEight(3): [apply $multiplyByEight 3]"
# 
# puts "multiplyByTwo(8): [apply $multiplyByTwo 8]"

# oo::class create Multiplier {
#     variable factor
#     constructor {a} {
#         set factor $a
#     }
#     method create {b} {
#         return [expr {$factor * $b}]
#     }
# }
# Multiplier create multiplyBySix 6
# puts "multiplyBySix(10): [multiplyBySix create 10]"
# 
# Multiplier create multiplyByTwo 2
# puts "multiplyByTwo(4): [multiplyByTwo create 4]"
# Multiplier create multiplyByEight [multiplyByTwo create 4]
# puts "multiplyByEight(10): [multiplyByEight create 10]"
