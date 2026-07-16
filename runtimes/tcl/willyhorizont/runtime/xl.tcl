package require TclOO

namespace eval xl {
    proc escape_string {s} {
        if {$s eq ""} {
            return ""
        }
        set r [string map { "\\" "\\\\" } $s]
        set r [string map {
            "\"" "\\\""
            "\n" "\\n"
            "\r" "\\r"
            "\t" "\\t"
        } $r]
        return $r
    }

    oo::class create Closure {
        variable cb
        variable fac
        constructor {cb_or_fac args} {
            if {[llength $args] > 0} {
                set fac $cb_or_fac
                set cb [lindex $args 0]
            } else {
                set fac {}
                set cb $cb_or_fac
            }
        }
        method call {args} {
            set va {}
            if {[llength $args] > 0} {
                set va [lindex $args 0]
            }
            set comb_args [list {*}$fac {*}$va]
            return [apply $cb $comb_args]
        }
    }

    proc closure {args} {
        return [Closure new {*}$args]
    }

    proc is_bool {v} {
        return [expr {$v eq "true" || $v eq "false"}]
    }

    proc is_int {v} {
        return [string is entier -strict $v]
    }

    proc is_float {v} {
        return [expr {[string is double -strict $v] && ![string is entier -strict $v]}]
    }

    proc is_closure {v} {
        if {[info commands $v] ne "" && [info object isa object $v]} {
            return [info object isa typeof $v ::xl::Closure]
        }
        return false
    }

    proc is_dict {v} {
        if {[catch {dict size $v}] != 0} {
            return false
        }
        set len [llength $v]
        if {$len % 2 != 0 || $len == 0} {
            return false
        }
        for {set i 0} {$i < $len} {incr i 2} {
            set pk [lindex $v $i]
            if {[is_closure $pk]} {
                return false
            }
        }
        return true
    }

    proc json_stringify {a {o {}}} {
        set p false
        if {[dict exists $o "pretty"]} {
            set p [dict get $o "pretty"]
        }
        set t [string repeat " " 4]
        set s [list [dict create "t" "v" "v" $a "d" 0]]
        set r ""
        while {[llength $s] > 0} {
            set c [lindex $s end]
            set s [lrange $s 0 end-1]
            if {[dict get $c "t"] eq "r"} {
                append r [dict get $c "v"]
                continue
            }
            set v [dict get $c "v"]
            set cur_d [dict get $c "d"]
            if {$v eq ""} {
                append r "\"\""
                continue
            }
            if {[is_bool $v]} {
                append r $v
                continue
            }
            if {[is_closure $v]} {
                append r "\"\[object Function\]\""
                continue
            }
            if {[is_int $v]} {
                append r $v
                continue
            }
            if {[is_float $v]} {
                append r $v
                continue
            }
            set child_d [expr {$cur_d + 1}]
            set cur_t [string repeat $t $cur_d]
            set child_t [string repeat $t $child_d]
            if {[is_dict $v]} {
                lappend s [dict create \
                    "t" "r" \
                    "v" [expr {$p ? "\n${cur_t}\}" : "\}"}] \
                    "d" $cur_d \
                ]
                set dpl [list]
                dict for {dk dv} $v {
                    lappend dpl [list $dk $dv]
                }
                for {set i [expr {[llength $dpl] - 1}]} {$i >= 0} {incr i -1} {
                    set dplel [lindex $dpl $i]
                    set dk [lindex $dplel 0]
                    set dv [lindex $dplel 1]
                    lappend s [dict create \
                        "t" "v" \
                        "v" $dv \
                        "d" $child_d \
                    ]
                    lappend s [dict create \
                        "t" "r" \
                        "v" [expr {$p ? "\"$dk\": " : "\"$dk\":"}] \
                        "d" $child_d \
                    ]
                    if {$i > 0} {
                        lappend s [dict create \
                            "t" "r" \
                            "v" [expr {$p ? ",\n${child_t}" : ","}] \
                            "d" $child_d \
                        ]
                    }
                }
                lappend s [dict create \
                    "t" "r" \
                    "v" [expr {$p ? "\{\n${child_t}" : "\{"}] \
                    "d" $child_d \
                ]
                continue
            }
            if {[string is list $v] && [llength $v] > 1} {
                lappend s [dict create \
                    "t" "r" \
                    "v" [expr {$p ? "\n${cur_t}\]" : "\]"}] \
                    "d" $cur_d \
                ]
                for {set i [expr {[llength $v] - 1}]} {$i >= 0} {incr i -1} {
                    lappend s [dict create \
                        "t" "v" \
                        "v" [lindex $v $i] \
                        "d" $child_d \
                    ]
                    if {$i > 0} {
                        lappend s [dict create \
                            "t" "r" \
                            "v" [expr {$p ? ",\n${child_t}" : ","}] \
                            "d" $child_d \
                        ]
                    }
                }
                lappend s [dict create \
                    "t" "r" \
                    "v" [expr {$p ? "\[\n${child_t}" : "\["}] \
                    "d" $child_d \
                ]
                continue
            }
            append r "\"" [escape_string $v] "\""
        }
        return $r
    }
}
