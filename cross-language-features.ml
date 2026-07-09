module Xl = Willyhorizont.Runtime

let () =
    (*
    1. support closure as value, or has workaround
    *)
    let say_hello = Xl.Type (fun va -> (
        let itr = Seq.to_dispenser (List.to_seq (Xl.to_list va)) in
        let callback_function = Xl.next itr in
        print_endline "hello";
        (Xl.to_closure callback_function) (Xl.Type [Xl.Type ()])
    )) in
    let _ = Xl.Type ((Xl.to_closure say_hello) (Xl.Type [Xl.Type (fun (_) -> (
        print_endline "world";
        Xl.Type ()
    ))])) in
    (* let create_multiplier = Xl.Type (fun va -> (
        let itr = Seq.to_dispenser (List.to_seq (Xl.to_list va)) in
        let aa = Xl.next itr in
        Xl.Type (fun va -> (
            let itr = Seq.to_dispenser (List.to_seq (Xl.to_list va)) in
            let bb = Xl.next itr in
            Xl.Type ((Xl.to_int aa) * (Xl.to_int bb))
        ))
    )) in
    let multiply_by_two = Xl.Type ((Xl.to_closure create_multiplier) (Xl.Type [Xl.Type (Xl.to_int 2)])) in
    let () = print_endline ("multiply_by_two(10): " ^ (Xl.to_string (Xl.json_stringify (Xl.Type [Xl.Type ((Xl.to_closure multiply_by_two) (Xl.to_int 10))])))) in *)
    (*
    2. support dynamic-typed value, or has workaround
    *)
    let some_py_list = Xl.Type [
        Xl.Type ();
        Xl.Type true;
        Xl.Type false;
        Xl.Type "foo";
        Xl.Type 0;
        Xl.Type (-123);
        Xl.Type (123.789);
        Xl.Type (-123.789);
        Xl.Type [Xl.Type 1; Xl.Type 2; Xl.Type 3];
        Xl.Type [Xl.Type [Xl.Type "foo"; Xl.Type "bar"]];
        Xl.Type (fun va -> (
            let itr = Seq.to_dispenser (List.to_seq (Xl.to_list va)) in
            let aa = Xl.next itr in
            let bb = Xl.next itr in
            Xl.Type ((Xl.to_int aa) * (Xl.to_int bb))
        ));
    ] in
    let () = print_endline ("some_py_list: " ^ (Xl.to_string (Xl.json_stringify (Xl.Type [some_py_list])))) in
    let () = print_endline ("some_py_list: " ^ (Xl.to_string (Xl.json_stringify (Xl.Type [some_py_list; Xl.Type [Xl.Type [Xl.Type "pretty"; Xl.Type true]]])))) in
    let some_py_dict = Xl.Type [
        Xl.Type [Xl.Type "some_py_none"; Xl.Type ()];
        Xl.Type [Xl.Type "some_py_boolean_true"; Xl.Type true];
        Xl.Type [Xl.Type "some_py_boolean_false"; Xl.Type false];
        Xl.Type [Xl.Type "some_js_string"; Xl.Type "foo"];
        Xl.Type [Xl.Type "some_js_int_positive"; Xl.Type 0];
        Xl.Type [Xl.Type "some_js_int_negative"; Xl.Type (-123)];
        Xl.Type [Xl.Type "some_js_float_positive"; Xl.Type (123.789)];
        Xl.Type [Xl.Type "some_js_float_negative"; Xl.Type (-123.789)];
        Xl.Type [Xl.Type "some_py_list"; Xl.Type [Xl.Type 1; Xl.Type 2; Xl.Type 3]];
        Xl.Type [Xl.Type "some_py_dict"; Xl.Type [Xl.Type [Xl.Type "foo"; Xl.Type "bar"]]];
        Xl.Type [Xl.Type "some_js_function"; Xl.Type (fun va -> (
            let itr = Seq.to_dispenser (List.to_seq (Xl.to_list va)) in
            let aa = Xl.next itr in
            let bb = Xl.next itr in
            Xl.Type ((Xl.to_int aa) * (Xl.to_int bb))
        ))];
    ] in
    let () = print_endline ("some_py_dict: " ^ (Xl.to_string (Xl.json_stringify (Xl.Type [some_py_dict])))) in
    let () = print_endline ("some_py_dict: " ^ (Xl.to_string (Xl.json_stringify (Xl.Type [some_py_dict; Xl.Type [Xl.Type [Xl.Type "pretty"; Xl.Type true]]])))) in
    ()
