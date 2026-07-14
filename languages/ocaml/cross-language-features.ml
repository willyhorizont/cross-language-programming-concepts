module Xl = Willyhorizont.Runtime.Xl

let () =
    (*
    1. support closure as value, or has workaround
    *)
    let say_hello = Xl.closure (fun va -> (
        let itr = Xl.iter va in
        let callback_function = Xl.next itr in
        print_endline "hello";
        Xl.call callback_function [Xl.none]
    )) in
    let _ = Xl.call say_hello [Xl.closure (fun (_) -> (
        print_endline "world";
        Xl.none
    ))] in
    let create_multiplier = Xl.closure (fun va -> (
        let itr = Xl.iter va in
        let aa = Xl.next itr in
        Xl.closure (fun va -> (
            let itr = Xl.iter va in
            let bb = Xl.next itr in
            Xl.int ((Xl.to_int aa) * (Xl.to_int bb))
        ))
    )) in
    let multiply_by_two = Xl.call create_multiplier [Xl.int 2] in
    print_endline ("multiply_by_two(10): " ^ (Xl.json_stringify [Xl.call multiply_by_two [Xl.int 10]]));
    let multiply_by_eight = Xl.call create_multiplier [Xl.int 8] in
    print_endline ("multiply_by_eight(4): " ^ (Xl.json_stringify [Xl.call multiply_by_eight [Xl.int 4]]));
    print_endline ("multiply_by_two(8): " ^ (Xl.json_stringify [Xl.call multiply_by_two [Xl.int 8]]));

    (*
    2. support dynamic-typed value, or has workaround
    *)
    let xl_list = Xl.list [
        Xl.none;
        Xl.bool true;
        Xl.bool false;
        Xl.string "foo";
        Xl.int (0);
        Xl.int (-123);
        Xl.float (123.789);
        Xl.float (-123.789);
        Xl.list [Xl.int (1); Xl.int (2); Xl.int (3)];
        Xl.dict [("foo", Xl.string "bar")];
        Xl.closure (fun va -> (
            let itr = Xl.iter va in
            let aa = Xl.next itr in
            let bb = Xl.next itr in
            Xl.int ((Xl.to_int aa) * (Xl.to_int bb))
        ));
    ] in
    print_endline ("xl_list: " ^ (Xl.json_stringify [xl_list]));
    print_endline ("xl_list: " ^ (Xl.json_stringify [xl_list; Xl.dict [("pretty", Xl.bool true)]]));
    let xl_dict = Xl.dict [
        ("xl_none", Xl.none);
        ("xl_bool_true", Xl.bool true);
        ("xl_bool_false", Xl.bool false);
        ("xl_string", Xl.string "foo");
        ("xl_int_positive", Xl.int (0));
        ("xl_int_negative", Xl.int (-123));
        ("xl_float_positive", Xl.float (123.789));
        ("xl_float_negative", Xl.float (-123.789));
        ("xl_list", Xl.list [Xl.int (1); Xl.int (2); Xl.int (3)]);
        ("xl_dict", Xl.dict [("foo", Xl.string "bar")]);
        ("xl_closure", Xl.closure (fun va -> (
            let itr = Xl.iter va in
            let aa = Xl.next itr in
            let bb = Xl.next itr in
            Xl.int ((Xl.to_int aa) * (Xl.to_int bb))
        )));
    ] in
    print_endline ("xl_dict" ^ (Xl.json_stringify [xl_dict]));
    print_endline ("xl_dict" ^ (Xl.json_stringify [xl_dict; Xl.dict [("pretty", Xl.bool true)]]));
    ()
