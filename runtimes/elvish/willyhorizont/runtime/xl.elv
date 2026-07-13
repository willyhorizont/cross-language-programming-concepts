use re
use str

var escape-string = {|s|
    if (is $s $nil) {
        put ""
    } else {
        var r = (to-string $s)
        set r = (re:replace "\\\\" "\\\\\\\\" $r)
        set r = (re:replace "\"" "\\\"" $r)
        set r = (re:replace "\n" "\\n" $r)
        set r = (re:replace "\r" "\\r" $r)
        set r = (re:replace "\t" "\\t" $r)
        put $r
    }
}

var json-stringify = {|a &pretty=$false|
    var p = $pretty
    var t = (str:repeat " " 4)
    var s = [[&"t"="v" &"v"=$a &"d"=0]]
    var r = ""
    while (> (count $s) 0) {
        var c = $s[-1]
        set s = $s[..-1]
        if (==s $c["t"] "r") {
            set r = $r$c["v"]
            continue
        }
        var v = $c["v"]
        var cur-d = $c["d"]
        var c-t = (kind-of $v)
        if (is $v $nil) {
            set r = $r"null"
            continue
        }
        if (==s $c-t "bool") {
            if $v { set r = $r"true" } else { set r = $r"false" }
            continue
        }
        if (==s $c-t "string") {
            set r = $r"\""($escape-string $v)"\""
            continue
        }
        if (==s $c-t "number") {
            set r = $r(to-string $v)
            continue
        }
        if (==s $c-t "fn") {
            set r = $r"\"[object Function]\""
            continue
        }
        if (==s $c-t "list") {
            var l-len = (count $v)
            if (== $l-len 0) {
                set r = $r"[]"
                continue
            }
            var child-d = (+ $cur-d 1)
            var slcb = "]"
            if $p { set slcb = "\n"(str:repeat $t $cur-d)"]" }
            set s = [ (all $s) [
                &"t"="r"
                &"v"=$slcb
                &"d"=$cur-d
            ] ]
            for i [(range (- $l-len 1) -1 &step=-1)] {
                set s = [ (all $s) [
                    &"t"="v"
                    &"v"=$v[$i]
                    &"d"=$child-d
                ] ]
                if (> $i 0) {
                    var slsep = ","
                    if $p { set slsep = ",\n"(str:repeat $t $child-d) }
                    set s = [ (all $s) [
                        &"t"="r"
                        &"v"=$slsep
                        &"d"=$child-d
                    ] ]
                }
            }
            var slob = "["
            if $p { set slob = "[\n"(str:repeat $t $child-d) }
            set s = [ (all $s) [
                &"t"="r"
                &"v"=$slob
                &"d"=$child-d
            ] ]
            continue
        }
        if (==s $c-t "map") {
            var dpl = [(keys $v | each {|k| put [$k $v[$k]] })]
            var dpl-len = (count $dpl)
            if (== $dpl-len 0) {
                set r = $r"{}"
                continue
            }
            var child-d = (+ $cur-d 1)
            var sdcb = "}"
            if $p { set sdcb = "\n"(str:repeat $t $cur-d)"}" }
            set s = [ (all $s) [
                &"t"="r"
                &"v"=$sdcb
                &"d"=$cur-d
            ] ]
            for i [(range (- $dpl-len 1) -1 &step=-1)] {
                var dp = $dpl[$i]
                var dk = $dp[0]
                var dv = $dp[1]
                set s = [ (all $s) [
                    &"t"="v"
                    &"v"=$dv
                    &"d"=$child-d
                ] ]
                var sdkvsep = "\""(to-string $dk)"\":"
                if $p { set sdkvsep = "\""(to-string $dk)"\": " }
                set s = [ (all $s) [
                    &"t"="r"
                    &"v"=$sdkvsep
                    &"d"=$child-d
                ] ]
                if (> $i 0) {
                    var sdpsep = ","
                    if $p { set sdpsep = ",\n"(str:repeat $t $child-d) }
                    set s = [ (all $s) [
                        &"t"="r"
                        &"v"=$sdpsep
                        &"d"=$child-d
                    ] ]
                }
            }
            var sdob = "{"
            if $p { set sdob = "{\n"(str:repeat $t $child-d) }
            set s = [ (all $s) [
                &"t"="r"
                &"v"=$sdob
                &"d"=$child-d
            ] ]
            continue
        }
        set r = $r"\""$c-t"\""
    }
    put $r
}

# TODO
# var std-json-stringify = {|a &pretty=$false|
#     # echo "xl_list:" (put $xl-list | to-json)
#     # echo "xl_list:" (put $xl-list | to-json | jq --indent 4)
#     # echo "xl_dict:" (put $xl-dict | to-json)
#     # echo "xl_dict:" (put $xl-dict | to-json | jq --indent 4)
# }