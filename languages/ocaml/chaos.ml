open Willyhorizont.Runtime

let () =
    let my_py_list = Any [
        Any (OcamlNone ());
        Any (OcamlBool true);
        Any (OcamlBool false);
        Any "foo";
        Any (OcamlInt 123);
        Any (OcamlInt (-123));
        Any (123.789);
        Any (-123.789);
    ] in
    let () = print_endline ("my_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [my_py_list])))) in
    let () = print_endline ("my_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [my_py_list; Any [Any "pretty"; Any (OcamlBool true)]])))) in
    let () = do_nothing (get_is_py_list my_py_list) in
    let () = do_nothing (get_first_list_item_matching_condition (Any [my_py_list; Any (fun any_variadic_arguments_py_list -> (
            let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
            let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
            let any_py_list_item = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
            if (get_is_js_int any_py_list_item) then
                Any (OcamlBool ((get_js_int_from_anything any_py_list_item) = 123))
            else
                Any (OcamlBool false)
        ))])) in
    let my_py_dict = Any [
        Any [Any "some_py_none"; Any (OcamlNone ())];
        Any [Any "some_py_boolean_true"; Any (OcamlBool true)];
        Any [Any "some_py_boolean_false"; Any (OcamlBool false)];
        Any [Any "some_js_string"; Any "foo"];
        Any [Any "some_js_int_positive"; Any (OcamlInt 123)];
        Any [Any "some_js_int_negative"; Any (OcamlInt (-123))];
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
    let () = do_nothing (multiply_version_one (Any [Any (OcamlInt 7); Any (OcamlInt 5)])) in

    let multiply_version_two = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        if List.length ocaml_variadic_arguments = 2 then
            let aa = List.nth ocaml_variadic_arguments 0 in
            let bb = List.nth ocaml_variadic_arguments 1 in
            Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
        else
            failwith "Error: Invalid arguments"
    )) in
    let () = do_nothing (multiply_version_two (Any [Any (OcamlInt 7); Any (OcamlInt 5)])) in

    let multiply_version_three = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        (* if (not (List.length args_list = 2)) then *)
        if List.length ocaml_variadic_arguments <> 2 then
            failwith "Error: Invalid arguments";
        let aa = List.nth ocaml_variadic_arguments 0 in
        let bb = List.nth ocaml_variadic_arguments 1 in
        Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
    )) in
    let () = do_nothing (multiply_version_three (Any [Any (OcamlInt 7); Any (OcamlInt 5)])) in

    let multiply_version_three_point_five = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let aa = List.nth ocaml_variadic_arguments 0 in
        let bb = List.nth ocaml_variadic_arguments 1 in
        Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
    )) in
    let () = do_nothing (multiply_version_three_point_five (Any [Any (OcamlInt 7); Any (OcamlInt 5)])) in

    let multiply_version_four = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_ref = ref ocaml_variadic_arguments in
        let aa = get_next_item_of_ocaml_py_list_ref (ocaml_variadic_arguments_ref) in
        let bb = get_next_item_of_ocaml_py_list_ref (ocaml_variadic_arguments_ref) in
        Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
    )) in
    let () = do_nothing (multiply_version_four (Any [Any (OcamlInt 7); Any (OcamlInt 5)])) in

    let multiply_version_five = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        (*  Turn list into Sequence, then turn it to Dispenser (Generator) *)
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let aa = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let bb = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
    )) in
    let () = do_nothing (multiply_version_five (Any [Any (OcamlInt 7); Any (OcamlInt 5)])) in
    ()
