using Willyhorizont.Runtime.Xl;

void main () {
    /*
    ' -- 1. support lambda as value, or has workaround
    */
    var say_hello = Xl.init_lambda ((va) => {
        var itr = va.iter ();
        var callback = itr.next ();
        print ("hello\n");
        callback.call ({ Xl.init_none () });
        return Xl.init_none ();
    });
    say_hello.call ({ Xl.init_lambda ((va) => {
        print ("world\n");
        return Xl.init_none ();
    }) });
    var create_multiplier = Xl.init_lambda ((va_aa) => {
        var itr_aa = va_aa.iter ();
        var aa = itr_aa.next ();
        return Xl.init_lambda ((va_bb) => {
            var itr_bb = va_bb.iter ();
            var bb = itr_bb.next ();
            return Xl.init_int (aa.to_int () * bb.to_int ());
        });
    });
    var multiply_by_two = create_multiplier.call ({ Xl.init_int (2) });
    print (@"multiply_by_two(10): $(multiply_by_two.call ({ Xl.init_int (10) }).to_int ())\n");
    var multiply_by_eight = create_multiplier.call ({ Xl.init_int (8) });
    print (@"multiply_by_eight(4): $(multiply_by_eight.call ({ Xl.init_int (4) }).to_int ())\n");
    print (@"multiply_by_two(8): $(multiply_by_two.call ({ Xl.init_int (8) }).to_int ())\n");

    /*
    ' -- 2. support dynamic-typed value, or has workaround
    */
    var xl_list = Xl.init_list ({
        Xl.init_none (),
        Xl.init_bool (true),
        Xl.init_bool (false),
        Xl.init_string ("foo"),
        Xl.init_int (0),
        Xl.init_int (-123),
        Xl.init_float (123.789),
        Xl.init_float (-123.789),
        Xl.init_list ({ Xl.init_int (1), Xl.init_int (2), Xl.init_int (3) }),
        Xl.init_dict ({ Xl.init_pair ("foo", Xl.init_string ("bar")) }),
        Xl.init_lambda ((va) => {
            var itr = va.iter ();
            var aa = itr.next ();
            var bb = itr.next ();
            return Xl.init_int (aa.to_int () * bb.to_int ());
        }),
    });
    print (@"xl_list: $(Xl.json_stringify(xl_list))\n");
    print (@"xl_list: $(Xl.json_stringify(xl_list, Xl.init_pair ("pretty", Xl.init_bool (true))))\n");
    var xl_dict = Xl.init_dict ({
        Xl.init_pair ("xl_none", Xl.init_none ()),
        Xl.init_pair ("xl_bool_true", Xl.init_bool (true)),
        Xl.init_pair ("xl_bool_false", Xl.init_bool (false)),
        Xl.init_pair ("xl_string", Xl.init_string ("foo")),
        Xl.init_pair ("xl_int_positive", Xl.init_int (0)),
        Xl.init_pair ("xl_int_negative", Xl.init_int (-123)),
        Xl.init_pair ("xl_float_positive", Xl.init_float (123.789)),
        Xl.init_pair ("xl_float_negative", Xl.init_float (-123.789)),
        Xl.init_pair ("xl_list", Xl.init_list ({ Xl.init_int (1), Xl.init_int (2), Xl.init_int (3) })),
        Xl.init_pair ("xl_dict", Xl.init_dict ({ Xl.init_pair ("foo", Xl.init_string ("bar")) })),
        Xl.init_pair ("xl_lambda", Xl.init_lambda ((va) => {
            var itr = va.iter ();
            var aa = itr.next ();
            var bb = itr.next ();
            return Xl.init_int (aa.to_int () * bb.to_int ());
        })),
    });
    print (@"xl_dict: $(Xl.json_stringify(xl_dict))\n");
    print (@"xl_dict: $(Xl.json_stringify(xl_dict, Xl.init_pair ("pretty", Xl.init_bool (true))))\n");
}
