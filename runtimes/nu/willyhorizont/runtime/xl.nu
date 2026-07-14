def string-repeat [s, n] {
    if $n <= 0 {
        ""
    } else {
        0..<$n | each { $s } | str join
    }
}

def escape-string [s] {
    if ($s == null) {
        ""
    } else {
        $s | into string
            | str replace --all "\\" "\\\\"
            | str replace --all "\"" "\\\""
            | str replace --all "\n" "\\n"
            | str replace --all "\r" "\\r"
            | str replace --all "\t" "\\t"
    }
}

export def json-stringify [a, --pretty] {
    let p = $pretty
    let t = (string-repeat " " 4)
    mut s = [{ "t": "v", "v": $a, "d": 0 }]
    mut r = ""
    while ($s | length) > 0 {
        let c = $s | last
        $s = ($s | drop 1)
        if $c."t" == "r" {
            $r = $r + $c."v"
            continue
        }
        let v = $c."v"
        let cur_d = $c."d"
        let c_t = ($v | describe)
        if $v == null {
            $r = $r + "null"
            continue
        }
        if ($c_t | str starts-with "bool") {
            $r = $r + (if $v { "true" } else { "false" })
            continue
        }
        if ($c_t | str starts-with "string") {
            $r = $r + "\"" + (escape-string $v) + "\""
            continue
        }
        if ($c_t | str starts-with "int") or ($c_t | str starts-with "float") {
            $r = $r + ($v | into string)
            continue
        }
        if ($c_t | str starts-with "closure") {
            $r = $r + '"[object Function]"'
            continue
        }
        if ($c_t | str starts-with "list") {
            let v_len = ($v | length)
            if $v_len == 0 {
                $r = $r + "[]"
                continue
            }
            let child_d = $cur_d + 1
            mut slcb = "]"
            if $p {
                $slcb = "\n" + (string-repeat " " (4 * $cur_d)) + "]"
            }
            $s = ($s | append {
                "t": "r",
                "v": $slcb,
                "d": $cur_d,
            })
            for i in (($v_len - 1)..0) {
                $s = ($s | append {
                    "t": "v",
                    "v": ($v | get $i),
                    "d": $child_d,
                })
                if $i > 0 {
                    mut slelsep = ","
                    if $p {
                        $slelsep = ",\n" + (string-repeat " " (4 * $child_d))
                    }
                    $s = ($s | append {
                        "t": "r",
                        "v": $slelsep,
                        "d": $child_d,
                    })
                }
            }
            mut slob = "["
            if $p {
                $slob = "[\n" + (string-repeat " " (4 * $child_d))
            }
            $s = ($s | append {
                "t": "r",
                "v": $slob,
                "d": $child_d,
            })
            continue
        }
        if ($c_t | str starts-with "record") {
            let dpl = ($v | columns | each { |k| { k: $k, v: ($v | get $k) } })
            let dpl_len = ($dpl | length)
            if $dpl_len == 0 {
                $r = $r + "{}"
                continue
            }
            let child_d = $cur_d + 1
            mut sdcb = "}"
            if $p {
                $sdcb = "\n" + (string-repeat " " (4 * $cur_d)) + "}"
            }
            $s = ($s | append {
                "t": "r",
                "v": $sdcb,
                "d": $cur_d,
            })
            for i in (($dpl_len - 1)..0) {
                let dp = ($dpl | get $i)
                let dK = $dp.k
                let dV = $dp.v
                $s = ($s | append {
                    "t": "v",
                    "v": $dV,
                    "d": $child_d,
                })
                mut dpkvsep = $'"($dK)":'
                if $p { $dpkvsep = $'"($dK)": ' }
                $s = ($s | append {
                    "t": "r",
                    "v": $dpkvsep,
                    "d": $child_d,
                })
                if $i > 0 {
                    mut slelsep = ","
                    if $p {
                        $slelsep = ",\n" + (string-repeat " " (4 * $child_d))
                    }
                    $s = ($s | append {
                        "t": "r",
                        "v": $slelsep,
                        "d": $child_d,
                    })
                }
            }
            mut sdob = "{"
            if $p {
                $sdob = "{\n" + (string-repeat " " (4 * $child_d))
            }
            $s = ($s | append {
                "t": "r",
                "v": $sdob,
                "d": $child_d,
            })
            continue
        }
        $r = $r + "\"" + $c_t + "\""
    }
    $r
}

# export def std-json-stringify [a, --pretty] {
#     # print $"xl_list: ($xl_list | to json --serialize)"
#     # print $"xl_list: ($xl_list | to json --serialize --indent 4)"
#     # print $"xl_dict: ($xl_dict | to json --serialize)"
#     # print $"xl_dict: ($xl_dict | to json --serialize --indent 4)"
# }
