open Willyhorizont.Runtime

let () =
    let my_py_list = Any [
        Any ();
        Any true;
        Any false;
        Any "foo";
        Any 123;
        Any (-123);
        Any (123.789);
        Any (-123.789);
    ] in
    let () = print_endline ("my_num_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [Any [Any 1; Any 2; Any 3]])))) in
    let () = print_endline ("my_num_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [Any [Any 1; Any 2; Any 3]; Any [Any "pretty"; Any true]])))) in
    let () = print_endline ("my_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [my_py_list])))) in
    let () = print_endline ("my_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [my_py_list; Any [Any "pretty"; Any true]])))) in

    let () = print_endline ("some_py_none: " ^ (get_js_string_from_anything (json_stringify (Any [Any (); Any [Any "pretty"; Any true]])))) in
    let () = print_endline ("some_py_boolean_true: " ^ (get_js_string_from_anything (json_stringify (Any [Any true; Any [Any "pretty"; Any true]])))) in
    let () = print_endline ("some_py_boolean_false: " ^ (get_js_string_from_anything (json_stringify (Any [Any false; Any [Any "pretty"; Any true]])))) in
    let () = print_endline ("some_js_string: " ^ (get_js_string_from_anything (json_stringify (Any [Any "foo"; Any [Any "pretty"; Any true]])))) in
    let () = print_endline ("some_js_int_positive: " ^ (get_js_string_from_anything (json_stringify (Any [Any ((123)); Any [Any "pretty"; Any true]])))) in
    let () = print_endline ("some_js_int_negative: " ^ (get_js_string_from_anything (json_stringify (Any [Any (-123); Any [Any "pretty"; Any true]])))) in
    let () = print_endline ("some_js_float_positive: " ^ (get_js_string_from_anything (json_stringify (Any [Any (123.789); Any [Any "pretty"; Any true]])))) in
    let () = print_endline ("some_js_float_negative: " ^ (get_js_string_from_anything (json_stringify (Any [Any (-123.789); Any [Any "pretty"; Any true]])))) in
    let () = print_endline ("some_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [Any [Any 1; Any 2; Any 3]; Any [Any "pretty"; Any true]])))) in
    let () = print_endline ("some_py_dict: " ^ (get_js_string_from_anything (json_stringify (Any [Any [Any [Any "foo"; Any "bar"]]; Any [Any "pretty"; Any true]])))) in

    let () = print_endline ("get_type some_py_none: " ^ (get_js_string_from_anything (get_type (Any ())))) in
    let () = print_endline ("get_type some_py_boolean_true: " ^ (get_js_string_from_anything (get_type (Any true)))) in
    let () = print_endline ("get_type some_py_boolean_false: " ^ (get_js_string_from_anything (get_type (Any false)))) in
    let () = print_endline ("get_type some_js_string: " ^ (get_js_string_from_anything (get_type (Any "foo")))) in
    let () = print_endline ("get_type some_js_int_positive: " ^ (get_js_string_from_anything (get_type (Any ((123)))))) in
    let () = print_endline ("get_type some_js_int_negative: " ^ (get_js_string_from_anything (get_type (Any (-123))))) in
    let () = print_endline ("get_type some_js_float_positive: " ^ (get_js_string_from_anything (get_type (Any (123.789))))) in
    let () = print_endline ("get_type some_js_float_negative: " ^ (get_js_string_from_anything (get_type (Any (-123.789))))) in
    let () = print_endline ("get_type some_py_list: " ^ (get_js_string_from_anything (get_type (Any [Any 1; Any 2; Any 3])))) in
    let () = print_endline ("get_type some_py_dict: " ^ (get_js_string_from_anything (get_type (Any [Any [Any "foo"; Any "bar"]])))) in

    let () = print_endline ("some_js_float_positive: " ^ (string_of_float (get_js_float_from_anything (Any (123.789))))) in
    let () = print_endline ("some_js_float_negative: " ^ (string_of_float (get_js_float_from_anything (Any (-123.789))))) in

    let () = do_nothing (get_is_py_list my_py_list) in
    let () = do_nothing (get_first_list_item_matching_condition (Any [my_py_list; Any (fun any_variadic_arguments_py_list -> (
            let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
            let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
            let any_py_list_item = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
            if (get_is_js_int any_py_list_item) then
                Any ((get_js_int_from_anything any_py_list_item) = (get_js_int_from_anything (Any 123)))
            else
                Any false
        ))])) in
    let my_py_dict = Any [
        Any [Any "some_py_none"; Any ()];
        Any [Any "some_py_boolean_true"; Any true];
        Any [Any "some_py_boolean_false"; Any false];
        Any [Any "some_js_string"; Any "foo"];
        Any [Any "some_js_int_positive"; Any 123];
        Any [Any "some_js_int_negative"; Any (-123)];
        Any [Any "some_js_float_positive"; Any (123.789)];
        Any [Any "some_js_float_negative"; Any (-123.789)];
    ] in
    let () = do_nothing (get_is_py_dict my_py_dict) in
    let () = do_nothing (get_py_dict_property (Any [my_py_dict; (Any "some_js_string")])) in

    let multiply_version_one = (fun any_variadic_arguments_py_list -> (
        match (get_py_list_from_anything any_variadic_arguments_py_list) with
        | [aa; bb] -> Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
        | _ -> failwith "Error: Invalid arguments"
    )) in
    let () = do_nothing (multiply_version_one (Any [Any 7; Any 5])) in

    let multiply_version_two = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        if List.length ocaml_variadic_arguments = 2 then
            let aa = List.nth ocaml_variadic_arguments 0 in
            let bb = List.nth ocaml_variadic_arguments 1 in
            Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
        else
            failwith "Error: Invalid arguments"
    )) in
    let () = do_nothing (multiply_version_two (Any [Any 7; Any 5])) in

    let multiply_version_three = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        (* if (not (List.length args_list = 2)) then *)
        if List.length ocaml_variadic_arguments <> 2 then
            failwith "Error: Invalid arguments";
        let aa = List.nth ocaml_variadic_arguments 0 in
        let bb = List.nth ocaml_variadic_arguments 1 in
        Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
    )) in
    let () = do_nothing (multiply_version_three (Any [Any 7; Any 5])) in

    let multiply_version_three_point_five = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let aa = List.nth ocaml_variadic_arguments 0 in
        let bb = List.nth ocaml_variadic_arguments 1 in
        Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
    )) in
    let () = do_nothing (multiply_version_three_point_five (Any [Any 7; Any 5])) in

    let multiply_version_four = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_ref = ref ocaml_variadic_arguments in
        let aa = get_next_item_of_ocaml_py_list_ref (ocaml_variadic_arguments_ref) in
        let bb = get_next_item_of_ocaml_py_list_ref (ocaml_variadic_arguments_ref) in
        Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
    )) in
    let () = do_nothing (multiply_version_four (Any [Any 7; Any 5])) in

    let multiply_version_five = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        (*  Turn list into Sequence, then turn it to Dispenser (Generator) *)
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let aa = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let bb = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
    )) in
    let () = do_nothing (multiply_version_five (Any [Any 7; Any 5])) in
    ()
