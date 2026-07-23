package xl;

use strict;
use warnings;
use v5.42.2;
no warnings "experimental::builtin";

sub escape_string {
    my ($s) = @_;
    if (!defined $s) {
        return "";
    }
    my $r = "$s";
    $r =~ s/\\/\\\\/g;
    $r =~ s/"/\\"/g;
    $r =~ s/\n/\\n/g;
    $r =~ s/\r/\\r/g;
    $r =~ s/\t/\\t/g;
    return $r;
}

sub json_stringify {
    my ($a, %o) = @_;
    my $p = $o{"pretty"} || 0;
    my $t = " " x 4;
    my $s = [{ "t" => "v", "v" => $a, "d" => 0 }];
    my $r = "";
    while (@$s > 0) {
        my $c = pop @$s;
        if ($c->{"t"} eq "r") {
            $r .= $c->{"v"};
            next;
        }
        my $v = $c->{"v"};
        my $cur_t = $c->{"d"};
        if (!defined $v) {
            $r .= "null";
            next;
        }
        my $rt = ref($v);
        if ($rt) {
            if ($rt eq "CODE") {
                $r .= "\"[object Function]\"";
                next;
            }
            if ($rt eq "ARRAY") {
                if (@$v == 0) {
                    $r .= "[]";
                    next;
                }
                my $child_t = $cur_t + 1;
                push @$s, {
                    "t" => "r",
                    "v" => $p ? "\n" . ($t x $cur_t) . "]" : "]",
                    "d" => $cur_t
                };
                for (my $i = $#$v; $i >= 0; $i--) {
                    push @$s, {
                        "t" => "v",
                        "v" => $v->[$i],
                        "d" => $child_t
                    };
                    if ($i > 0) {
                        push @$s, {
                            "t" => "r",
                            "v" => $p ? ",\n" . ($t x $child_t) : ",",
                            "d" => $child_t
                        };
                    }
                }
                push @$s, {
                    "t" => "r",
                    "v" => $p ? "[\n" . ($t x $child_t) : "[",
                    "d" => $child_t
                };
                next;
            }
            if ($rt eq "HASH") {
                my @keys = sort keys %$v;
                if (@keys == 0) {
                    $r .= "{}";
                    next;
                }
                my $child_t = $cur_t + 1;
                push @$s, {
                    "t" => "r",
                    "v" => $p ? "\n" . ($t x $cur_t) . "}" : "}",
                    "d" => $cur_t
                };
                for (my $i = $#keys; $i >= 0; $i--) {
                    my $dk = $keys[$i];
                    push @$s, {
                        "t" => "v",
                        "v" => $v->{$dk},
                        "d" => $child_t
                    };
                    push @$s, {
                        "t" => "r",
                        "v" => $p ? "\"$dk\": " : "\"$dk\":",
                        "d" => $child_t
                    };
                    if ($i > 0) {
                        push @$s, {
                            "t" => "r",
                            "v" => $p ? ",\n" . ($t x $child_t) : ",",
                            "d" => $child_t
                        };
                    }
                }
                push @$s, {
                    "t" => "r",
                    "v" => $p ? "{\n" . ($t x $child_t) : "{",
                    "d" => $child_t
                };
                next;
            }
            $r .= "\"$rt\"";
            next;
        }
        if (builtin::is_bool($v)) {
            $r .= $v ? "true" : "false";
            next;
        }
        if ($v =~ /^-?(?:0|[1-9]\d*)(?:\.\d+)?$/) {
            $r .= $v;
        } else {
            $r .= "\"" . escape_string($v) . "\"";
        }
    }
    return $r;
}

1;
