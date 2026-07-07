use strict;
use warnings;
use v5.42.2;
use File::Spec;
use FindBin;
require File::Spec->catfile($FindBin::Bin, "..", "..", "runtimes", "perl", "willyhorizont", "runtime.pl");

=pod
1. support closure as value, or has workaround
=cut
my $say_hello = sub {
    my ($callback_function) = @_;
    say("hello");
    &$callback_function();
};
&$say_hello(sub {
    say("world");
});
my $create_multiplier = sub {
    my ($aa) = @_;
    return sub {
        my ($bb) = @_;
        return ($aa * $bb);
    };
};
my $multiply_by_two = &$create_multiplier(2);
say("multiply_by_two(10): " . &$multiply_by_two(10));
my $multiply_by_eight = &$create_multiplier(8);
say("multiply_by_eight(4): " . &$multiply_by_eight(4));
say("multiply_by_two(8): " . &$multiply_by_two(8));

=pod
2. support dynamic-typed value, or has workaround
=cut
my $xl_list = [
    undef,
    builtin::true,
    builtin::false,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    {"foo" => "bar"},
    sub {
        my ($aa, $bb) = @_;
        return ($aa * $bb);
    },
];
say("xl_list: " . xl::json_stringify($xl_list));
say("xl_list: " . xl::json_stringify($xl_list, "pretty" => builtin::true));
my $xl_dict = {
    "xl_none" => undef,
    "xl_bool_true" => builtin::true,
    "xl_bool_false" => builtin::false,
    "xl_string" => "foo",
    "xl_int_positive" => 0,
    "xl_int_negative" => -123,
    "xl_float_positive" => 123.789,
    "xl_float_negative" => -123.789,
    "xl_list" => [1, 2, 3],
    "xl_dict" => {"foo" => "bar"},
    "xl_closure" => sub {
        my ($aa, $bb) = @_;
        return ($aa * $bb);
    },
};
say("xl_dict: " . xl::json_stringify($xl_dict));
say("xl_dict: " . xl::json_stringify($xl_dict, "pretty" => builtin::true));
