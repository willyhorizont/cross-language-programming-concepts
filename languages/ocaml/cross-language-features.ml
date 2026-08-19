module Xl = Willyhorizont.Runtime.Xl

let () =
    (*
    // # -- 1. support lambda as value, or has workaround
    *)
    let say_hello = Xl.init_lambda (fun va -> (
        let itr = Xl.iter va in
        let callback = Xl.next itr in
        print_endline "hello";
        Xl.call callback [Xl.init_none]
    )) in
    let _ = Xl.call say_hello [Xl.init_lambda (fun (_) -> (
        print_endline "world";
        Xl.init_none
    ))] in
    let create_multiplier = Xl.init_lambda (fun va -> (
        let itr = Xl.iter va in
        let aa = Xl.next itr in
        Xl.init_lambda (fun va -> (
            let itr = Xl.iter va in
            let bb = Xl.next itr in
            Xl.init_int ((Xl.to_int aa) * (Xl.to_int bb))
        ))
    )) in
    let multiply_by_two = Xl.call create_multiplier [Xl.init_int 2] in
    print_endline ("multiply_by_two(10): " ^ (Xl.json_stringify [Xl.call multiply_by_two [Xl.init_int 10]]));
    let multiply_by_eight = Xl.call create_multiplier [Xl.init_int 8] in
    print_endline ("multiply_by_eight(4): " ^ (Xl.json_stringify [Xl.call multiply_by_eight [Xl.init_int 4]]));
    print_endline ("multiply_by_two(8): " ^ (Xl.json_stringify [Xl.call multiply_by_two [Xl.init_int 8]]));

    (*
    // # -- 2. support dynamic-typed value, or has workaround
    *)
    let xl_list = Xl.init_list [
        Xl.init_none;
        Xl.init_bool true;
        Xl.init_bool false;
        Xl.init_string "foo";
        Xl.init_int (0);
        Xl.init_int (-123);
        Xl.init_float (123.789);
        Xl.init_float (-123.789);
        Xl.init_list [Xl.init_int (1); Xl.init_int (2); Xl.init_int (3)];
        Xl.init_dict [("foo", Xl.init_string "bar")];
        Xl.init_lambda (fun va -> (
            let itr = Xl.iter va in
            let aa = Xl.next itr in
            let bb = Xl.next itr in
            Xl.init_int ((Xl.to_int aa) * (Xl.to_int bb))
        ));
    ] in
    print_endline ("xl_list: " ^ (Xl.json_stringify [xl_list]));
    print_endline ("xl_list: " ^ (Xl.json_stringify [xl_list; Xl.init_dict [("pretty", Xl.init_bool true)]]));
    let xl_dict = Xl.init_dict [
        ("xl_none", Xl.init_none);
        ("xl_bool_true", Xl.init_bool true);
        ("xl_bool_false", Xl.init_bool false);
        ("xl_string", Xl.init_string "foo");
        ("xl_int_positive", Xl.init_int (0));
        ("xl_int_negative", Xl.init_int (-123));
        ("xl_float_positive", Xl.init_float (123.789));
        ("xl_float_negative", Xl.init_float (-123.789));
        ("xl_list", Xl.init_list [Xl.init_int (1); Xl.init_int (2); Xl.init_int (3)]);
        ("xl_dict", Xl.init_dict [("foo", Xl.init_string "bar")]);
        ("xl_lambda", Xl.init_lambda (fun va -> (
            let itr = Xl.iter va in
            let aa = Xl.next itr in
            let bb = Xl.next itr in
            Xl.init_int ((Xl.to_int aa) * (Xl.to_int bb))
        )));
    ] in
    print_endline ("xl_dict" ^ (Xl.json_stringify [xl_dict]));
    print_endline ("xl_dict" ^ (Xl.json_stringify [xl_dict; Xl.init_dict [("pretty", Xl.init_bool true)]]));
    ()
