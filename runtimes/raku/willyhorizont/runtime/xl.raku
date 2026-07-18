use v6.d;

module xl {
    our sub escape-string($s) {
        if !defined($s) {
            return ""; 
        }
        my $r = Str($s);
        $r = $r.subst("\\", "\\\\", :g);
        $r = $r.subst("\"", "\\\"", :g);
        $r = $r.subst("\n", "\\n",  :g);
        $r = $r.subst("\r", "\\r",  :g);
        $r = $r.subst("\t", "\\t",  :g);
        return $r;
    }

    our sub json-stringify($a, :$pretty = False) {
        my $p = $pretty;
        my $t = " " x 4;
        my @s = ( { "t" => "v", "v" => $a, "d" => 0 }, );
        my $r = "";
        while elems(@s) > 0 {
            my $c = pop(@s);
            if $c{"t"} eq "r" {
                $r ~= $c{"v"};
                next;
            }
            my $v = $c{"v"};
            my $cur-d = $c{"d"};
            if !defined($v) {
                $r ~= "null";
                next;
            }
            if $v ~~ Bool {
                $r ~= $v ?? "true" !! "false";
                next;
            }
            if $v ~~ Str {
                $r ~= "\"" ~ escape-string($v) ~ "\"";
                next;
            }
            if $v ~~ Numeric {
                $r ~= Str($v);
                next;
            }
            if $v ~~ Callable {
                $r ~= "\"[object Function]\"";
                next;
            }
            if $v ~~ Positional {
                if elems($v) == 0 {
                    $r ~= "[]";
                    next;
                }
                my $child-d = $cur-d + 1;
                push(@s, {
                    "t" => "r",
                    "v" => $p ?? "\n" ~ ($t x $cur-d) ~ "]" !! "]",
                    "d" => $cur-d
                });
                loop (my $i = elems($v) - 1; $i >= 0; $i -= 1) {
                    push(@s, {
                        "t" => "v",
                        "v" => $v[$i],
                        "d" => $child-d
                    });
                    if $i > 0 {
                        push(@s, {
                            "t" => "r",
                            "v" => $p ?? ",\n" ~ ($t x $child-d) !! ",",
                            "d" => $child-d
                        });
                    }
                }
                push(@s, {
                    "t" => "r",
                    "v" => $p ?? "[\n" ~ ($t x $child-d) !! "[",
                    "d" => $child-d
                });
                next;
            }
            if $v ~~ Associative {
                my @dpl = pairs($v);
                if elems(@dpl) == 0 {
                    $r ~= "\{}";
                    next;
                }
                my $child-d = $cur-d + 1;
                push(@s, {
                    "t" => "r",
                    "v" => $p ?? "\n" ~ ($t x $cur-d) ~ "}" !! "}",
                    "d" => $cur-d
                });
                loop (my $i = elems(@dpl) - 1; $i >= 0; $i -= 1) {
                    my $dk = @dpl[$i].key;
                    my $dv = @dpl[$i].value;
                    push(@s, {
                        "t" => "v",
                        "v" => $dv,
                        "d" => $child-d
                    });
                    push(@s, {
                        "t" => "r",
                        "v" => $p ?? "\"" ~ Str($dk) ~ "\": " !! "\"" ~ Str($dk) ~ "\":",
                        "d" => $child-d
                    });
                    if $i > 0 {
                        push(@s, {
                            "t" => "r",
                            "v" => $p ?? ",\n" ~ ($t x $child-d) !! ",",
                            "d" => $child-d
                        });
                    }
                }
                push(@s, {
                    "t" => "r",
                    "v" => $p ?? "\{\n" ~ ($t x $child-d) !! "\{",
                    "d" => $child-d
                });
                next;
            }
            $r ~= "\"" ~ Str($v.WHAT.HOW.name($v)) ~ "\"";
        }
        return $r;
    }
}
