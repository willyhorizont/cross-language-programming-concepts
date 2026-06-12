open Willyhorizont.Runtime

let () =
    let my_python_like_list = Any [
        Any ();
        Any true;
        Any false;
        Any "foo";
        Any (123);
        Any (-123);
        Any (123.789);
        Any (-123.789);
    ]
    in
    let () = 
        do_nothing (get_is_py_list my_python_like_list)
    in
    let () = 
        do_nothing (get_first_list_item_matching_condition my_python_like_list (fun anything -> (
            match (parse_py_list anything) with
            | [any_py_list_item; _; _] -> (
                if (get_is_js_int any_py_list_item) then
                    (any_py_list_item = Any (123))
                else
                    false
            )
            | _ -> failwith "Error: invalid arguments"
        )))
    in
    let my_py_dict = Any [
        Any [Any "some_py_none"; Any ()];
        Any [Any "some_py_boolean_true"; Any true];
        Any [Any "some_py_boolean_false"; Any false];
        Any [Any "some_js_string"; Any "foo"];
        Any [Any "some_js_int_positive"; Any (123)];
        Any [Any "some_js_int_negative"; Any (-123)];
        Any [Any "some_js_float_positive"; Any (123.789)];
        Any [Any "some_js_float_negative"; Any (-123.789)];
    ]
    in
    let () = 
        do_nothing (get_is_py_dict my_py_dict)
    in

    let multiply_version_one = (fun anything -> (
        match (parse_py_list anything) with
        | [aa; bb] -> Any ((parse_js_int aa) * (parse_js_int bb))
        | _ -> failwith "Error: invalid arguments"
    ))
    in
    let () = 
        do_nothing (multiply_version_one (Any [Any 7; Any 5]))
    in

    let multiply_version_two = (fun anything -> (
        let ocaml_variadic_arguments = parse_py_list anything
        in
        if List.length ocaml_variadic_arguments = 2 then
            let aa = List.nth ocaml_variadic_arguments 0
            in
            let bb = List.nth ocaml_variadic_arguments 1
            in
            Any ((parse_js_int aa) * (parse_js_int bb))
        else
            failwith "Error: invalid arguments"
    ))
    in
    let () = 
        do_nothing (multiply_version_two (Any [Any 7; Any 5]))
    in

    let multiply_version_three = (fun anything -> (
        let ocaml_variadic_arguments = parse_py_list anything
        in
        (* if (not (List.length args_list = 2)) then *)
        if List.length ocaml_variadic_arguments <> 2 then
            failwith "Error: invalid arguments";
        let aa = List.nth ocaml_variadic_arguments 0
        in
        let bb = List.nth ocaml_variadic_arguments 1
        in
        Any ((parse_js_int aa) * (parse_js_int bb))
    ))
    in
    let () = 
        do_nothing (multiply_version_three (Any [Any 7; Any 5]))
    in

    let multiply_version_three_point_five = (fun anything -> (
        let ocaml_variadic_arguments = parse_py_list anything
        in
        let aa = List.nth ocaml_variadic_arguments 0
        in
        let bb = List.nth ocaml_variadic_arguments 1
        in
        Any ((parse_js_int aa) * (parse_js_int bb))
    ))
    in
    let () = 
        do_nothing (multiply_version_three_point_five (Any [Any 7; Any 5]))
    in

    let multiply_version_four = (fun anything -> (
        let ocaml_variadic_arguments = parse_py_list anything
        in
        let ocaml_variadic_arguments_ref = ref ocaml_variadic_arguments
        in
        let aa = get_next_item_of_py_list_ref (ocaml_variadic_arguments_ref)
        in
        let bb = get_next_item_of_py_list_ref (ocaml_variadic_arguments_ref)
        in
        
        Any ((parse_js_int aa) * (parse_js_int bb))
    ))
    in
    let () = 
        do_nothing (multiply_version_four (Any [Any 7; Any 5]))
    in

    let multiply_version_five = (fun anything -> (
        let ocaml_variadic_arguments = parse_py_list anything
        in
        (*  Turn list into Sequence, then turn it to Dispenser (Generator) *)
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments)
        in
        let aa = get_next_item_of_generator (ocaml_variadic_arguments_generator)
        in
        let bb = get_next_item_of_generator (ocaml_variadic_arguments_generator)
        in
        Any ((parse_js_int aa) * (parse_js_int bb))
    ))
    in
    let () = 
        do_nothing (multiply_version_five (Any [Any 7; Any 5]))
    in

    ()
