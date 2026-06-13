open Willyhorizont.Runtime

let () =
    print_endline ("get_type some_py_none: " ^ (get_js_string_from_anything (get_type (Any ()))));
    print_endline ("get_type some_py_boolean_true: " ^ (get_js_string_from_anything (get_type (Any true))));
    print_endline ("get_type some_py_boolean_false: " ^ (get_js_string_from_anything (get_type (Any false))));
    print_endline ("get_type some_js_string: " ^ (get_js_string_from_anything (get_type (Any "foo"))));
    print_endline ("get_type some_js_int_positive: " ^ (get_js_string_from_anything (get_type (Any 0))));
    print_endline ("get_type some_js_int_negative: " ^ (get_js_string_from_anything (get_type (Any (-123)))));
    print_endline ("get_type some_js_float_positive: " ^ (get_js_string_from_anything (get_type (Any (123.789)))));
    print_endline ("get_type some_js_float_negative: " ^ (get_js_string_from_anything (get_type (Any (-123.789)))));
    print_endline ("get_type some_py_list: " ^ (get_js_string_from_anything (get_type (Any [Any 1; Any 2; Any 3]))));
    print_endline ("get_type some_py_dict: " ^ (get_js_string_from_anything (get_type (Any [Any [Any "foo"; Any "bar"]]))));
    print_endline ("get_type some_js_function: " ^ (get_js_string_from_anything (get_type (Any (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let aa = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let bb = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
    ))))));

    print_endline ("");

    let some_py_none = (Any ()) in
    let some_py_boolean_true = (Any true) in
    let some_py_boolean_false = (Any false) in
    let some_js_string = (Any "foo") in
    let some_js_int_positive = (Any 0) in
    let some_js_int_negative = (Any (-123)) in
    let some_js_float_positive = (Any (123.789)) in
    let some_js_float_negative = (Any (-123.789)) in
    let some_py_list = (Any [Any 1; Any 2; Any 3]) in
    let some_py_dict = (Any [Any [Any "foo"; Any "bar"]]) in
    let some_js_function = (Any (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let aa = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let bb = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
    ))) in

    print_endline ("");

    let my_py_list = Any [
        Any ();
        Any true;
        Any false;
        Any "foo";
        Any 0;
        Any (-123);
        Any (123.789);
        Any (-123.789);
        Any [Any 1; Any 2; Any 3];
        Any [Any [Any "foo"; Any "bar"]];
        Any (fun any_variadic_arguments_py_list -> (
            let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
            let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
            let aa = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
            let bb = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
            Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
        ));
    ] in
    print_endline ("get_is_py_list(my_py_list): " ^ (string_of_bool (get_is_py_list my_py_list)));
    print_endline ("string_of_int get_js_int_from_anything my_py_list[0]: " ^ (string_of_int (get_js_int_from_anything (List.nth (get_py_list_from_anything my_py_list) 0))));
    print_endline ("string_of_bool get_py_bool_from_anything my_py_list[0]: " ^ (string_of_bool (get_py_bool_from_anything (List.nth (get_py_list_from_anything my_py_list) 0))));
    (* let () = print_endline ("string_of_int get_py_none_from_anything my_py_list[0]: " ^ (string_of_int (get_py_none_from_anything (List.nth (get_py_list_from_anything my_py_list) 0)))) in *)
    (* let () = print_endline ("string_of_bool get_py_none_from_anything my_py_list[0]: " ^ (string_of_bool (get_py_none_from_anything (List.nth (get_py_list_from_anything my_py_list) 0)))) in *)
    print_endline ("string_of_bool get_py_none_from_anything my_py_list[0] = (): " ^ (string_of_bool ((get_py_none_from_anything (List.nth (get_py_list_from_anything my_py_list) 0)) = ())));
    print_endline ("my_py_list[0]: " ^ (string_of_py_none (get_py_none_from_anything (List.nth (get_py_list_from_anything my_py_list) 0))));
    print_endline ("my_py_list[1]: " ^ (string_of_bool (get_py_bool_from_anything (List.nth (get_py_list_from_anything my_py_list) 1))));
    print_endline ("my_py_list[2]: " ^ (string_of_bool (get_py_bool_from_anything (List.nth (get_py_list_from_anything my_py_list) 2))));
    print_endline ("my_py_list[3]: " ^ (get_js_string_from_anything (List.nth (get_py_list_from_anything my_py_list) 3)));
    print_endline ("my_py_list[4]: " ^ (string_of_int (get_js_int_from_anything (List.nth (get_py_list_from_anything my_py_list) 4))));
    print_endline ("my_py_list[5]: " ^ (string_of_int (get_js_int_from_anything (List.nth (get_py_list_from_anything my_py_list) 5))));
    print_endline ("my_py_list[6]: " ^ (string_of_float (get_js_float_from_anything (List.nth (get_py_list_from_anything my_py_list) 6))));
    print_endline ("my_py_list[7]: " ^ (string_of_float (get_js_float_from_anything (List.nth (get_py_list_from_anything my_py_list) 7))));

    print_endline ("");

    let my_py_dict = Any [
        Any [Any "some_py_none"; Any ()];
        Any [Any "some_py_boolean_true"; Any true];
        Any [Any "some_py_boolean_false"; Any false];
        Any [Any "some_js_string"; Any "foo"];
        Any [Any "some_js_int_positive"; Any 0];
        Any [Any "some_js_int_negative"; Any (-123)];
        Any [Any "some_js_float_positive"; Any (123.789)];
        Any [Any "some_js_float_negative"; Any (-123.789)];
        Any [Any "some_py_list"; Any [Any 1; Any 2; Any 3]];
        Any [Any "some_py_dict"; Any [Any [Any "foo"; Any "bar"]]];
        Any [Any "some_js_function"; Any (fun any_variadic_arguments_py_list -> (
            let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
            let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
            let aa = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
            let bb = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
            Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
        ))];
    ] in
    print_endline ("get_is_py_dict(my_py_dict): " ^ (string_of_bool (get_is_py_dict my_py_dict)));
    print_endline ("my_py_dict[\"some_py_none\"]: " ^ (string_of_py_none (get_py_bool_from_anything (get_py_dict_property (Any [my_py_dict; Any "some_py_none"])))));
    print_endline ("my_py_dict[\"some_py_boolean_true\"]: " ^ (string_of_bool (get_py_bool_from_anything (get_py_dict_property (Any [my_py_dict; Any "some_py_boolean_true"])))));
    print_endline ("my_py_dict[\"some_py_boolean_false\"]: " ^ (string_of_bool (get_py_bool_from_anything (get_py_dict_property (Any [my_py_dict; Any "some_py_boolean_false"])))));
    print_endline ("my_py_dict[\"some_js_string\"]: " ^ (get_js_string_from_anything (get_py_dict_property (Any [my_py_dict; Any "some_js_string"]))));
    print_endline ("my_py_dict[\"some_js_int_positive\"]: " ^ (string_of_int (get_js_int_from_anything (get_py_dict_property (Any [my_py_dict; Any "some_js_int_positive"])))));
    print_endline ("my_py_dict[\"some_js_int_negative\"]: " ^ (string_of_int (get_js_int_from_anything (get_py_dict_property (Any [my_py_dict; Any "some_js_int_negative"])))));
    print_endline ("my_py_dict[\"some_js_float_positive\"]: " ^ (string_of_float (get_js_float_from_anything (get_py_dict_property (Any [my_py_dict; Any "some_js_float_positive"])))));
    print_endline ("my_py_dict[\"some_js_float_negative\"]: " ^ (string_of_float (get_js_float_from_anything (get_py_dict_property (Any [my_py_dict; Any "some_js_float_negative"])))));

    print_endline ("");
    
    print_endline ("Any () = Any (): " ^ (string_of_bool (Any () = Any ())));

    print_endline ("");

    print_endline ("Any () = Any false: " ^ (string_of_bool (Any () = Any false)));
    print_endline ("Any () = Any 0: " ^ (string_of_bool (Any () = Any 0)));
    print_endline ("Any false = Any (): " ^ (string_of_bool (Any false = Any ())));
    print_endline ("Any false = Any 0: " ^ (string_of_bool (Any false = Any 0)));
    print_endline ("Any 0 = Any (): " ^ (string_of_bool (Any 0 = Any ())));
    print_endline ("Any 0 = Any false: " ^ (string_of_bool (Any 0 = Any false)));

    print_endline ("");

    let my_ocaml_zero_list = Any [ Any (); Any false; Any 0 ] in

    print_endline ("my_ocaml_zero_list[0]: " ^ (string_of_py_none (get_py_none_from_anything (List.nth (get_py_list_from_anything my_ocaml_zero_list) 0))));
    print_endline ("my_ocaml_zero_list[1]: " ^ (string_of_py_none (get_py_none_from_anything (List.nth (get_py_list_from_anything my_ocaml_zero_list) 1))));
    print_endline ("my_ocaml_zero_list[2]: " ^ (string_of_py_none (get_py_none_from_anything (List.nth (get_py_list_from_anything my_ocaml_zero_list) 2))));

    print_endline ("");

    test_py_list_insert_tail ();

    print_endline ("");

    print_endline ("test_json_stringify: my_py_list");
    test_json_stringify (Any [my_py_list]);

    print_endline ("");

    print_endline ("test_json_stringify: my_py_list pretty");
    test_json_stringify (Any [my_py_list; Any [Any [Any "pretty"; Any true]]]);

    print_endline ("");

    print_endline ("test_json_stringify: my_py_dict");
    test_json_stringify (Any [my_py_dict]);

    print_endline ("");

    print_endline ("test_json_stringify: my_py_dict pretty");
    test_json_stringify (Any [my_py_dict; Any [Any [Any "pretty"; Any true]]]);

    print_endline ("");

    (* print_endline ("some_py_none:");
    test_json_stringify (Any [some_py_none; Any [Any [Any "pretty"; Any true]]]);

    print_endline ("");

    print_endline ("some_py_boolean_true:");
    test_json_stringify (Any [some_py_boolean_true; Any [Any [Any "pretty"; Any true]]]);

    print_endline ("");

    print_endline ("some_py_boolean_false:");
    test_json_stringify (Any [some_py_boolean_false; Any [Any [Any "pretty"; Any true]]]);

    print_endline ("");

    print_endline ("some_js_string:");
    test_json_stringify (Any [some_js_string; Any [Any [Any "pretty"; Any true]]]);

    print_endline ("");

    print_endline ("some_js_int_positive:");
    test_json_stringify (Any [some_js_int_positive; Any [Any [Any "pretty"; Any true]]]);

    print_endline ("");

    print_endline ("some_js_int_negative:");
    test_json_stringify (Any [some_js_int_negative; Any [Any [Any "pretty"; Any true]]]);

    print_endline ("");

    print_endline ("some_js_float_positive:");
    test_json_stringify (Any [some_js_float_positive; Any [Any [Any "pretty"; Any true]]]);

    print_endline ("");

    print_endline ("some_js_float_negative:");
    test_json_stringify (Any [some_js_float_negative; Any [Any [Any "pretty"; Any true]]]);

    print_endline ("");

    print_endline ("some_py_list:");
    test_json_stringify (Any [some_py_list; Any [Any [Any "pretty"; Any true]]]);

    print_endline ("");

    print_endline ("some_py_dict:");
    test_json_stringify (Any [some_py_dict; Any [Any [Any "pretty"; Any true]]]);

    print_endline ("");

    print_endline ("some_js_function:");
    test_json_stringify (Any [some_js_function; Any [Any [Any "pretty"; Any true]]]);

    print_endline (""); *)

    do_nothing some_py_none;
    do_nothing some_py_boolean_true;
    do_nothing some_py_boolean_false;
    do_nothing some_js_string;
    do_nothing some_js_int_positive;
    do_nothing some_js_int_negative;
    do_nothing some_js_float_positive;
    do_nothing some_js_float_negative;
    do_nothing some_py_list;
    do_nothing some_py_dict;
    do_nothing some_js_function;

    let multiply = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let aa = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let bb = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
    )) in
    print_endline ("multiply(7, 5): " ^ (string_of_int (get_js_int_from_anything (multiply (Any [Any 7; Any 5])))));

    (* let () = print_endline ("get_first_list_item_matching_condition(123): " ^ (get_js_string_from_anything (get_first_list_item_matching_condition (Any [my_py_list; Any (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let any_py_list_item = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        if (get_is_js_int any_py_list_item) then
            Any ((get_js_int_from_anything any_py_list_item) = (get_js_int_from_anything (Any 123)))
        else
            Any false
    ))])))) in *)
    (* let () = do_nothing (get_first_list_item_matching_condition (Any [my_py_list; Any (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let any_py_list_item = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        if (get_is_js_int any_py_list_item) then
            Any ((get_js_int_from_anything any_py_list_item) = (get_js_int_from_anything (Any 123)))
        else
            Any false
    ))])) in *)

    (* let () = print_endline ("my_num_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [Any [Any 1; Any 2; Any 3]])))) in *)
    (* let () = print_endline ("my_num_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [Any [Any 1; Any 2; Any 3]; Any [Any "pretty"; Any true]])))) in *)
    (* let () = print_endline ("my_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [my_py_list])))) in *)
    (* let () = print_endline ("my_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [my_py_list; Any [Any "pretty"; Any true]])))) in *)

    (* let () = print_endline ("some_py_none: " ^ (get_js_string_from_anything (json_stringify (Any [Any (); Any [Any "pretty"; Any true]])))) in *)
    (* let () = print_endline ("some_py_boolean_true: " ^ (get_js_string_from_anything (json_stringify (Any [Any true; Any [Any "pretty"; Any true]])))) in *)
    (* let () = print_endline ("some_py_boolean_false: " ^ (get_js_string_from_anything (json_stringify (Any [Any false; Any [Any "pretty"; Any true]])))) in *)
    (* let () = print_endline ("some_js_string: " ^ (get_js_string_from_anything (json_stringify (Any [Any "foo"; Any [Any "pretty"; Any true]])))) in *)
    (* let () = print_endline ("some_js_int_positive: " ^ (get_js_string_from_anything (json_stringify (Any [Any 123; Any [Any "pretty"; Any true]])))) in *)
    (* let () = print_endline ("some_js_int_negative: " ^ (get_js_string_from_anything (json_stringify (Any [Any (-123); Any [Any "pretty"; Any true]])))) in *)
    (* let () = print_endline ("some_js_float_positive: " ^ (get_js_string_from_anything (json_stringify (Any [Any (123.789); Any [Any "pretty"; Any true]])))) in *)
    (* let () = print_endline ("some_js_float_negative: " ^ (get_js_string_from_anything (json_stringify (Any [Any (-123.789); Any [Any "pretty"; Any true]])))) in *)
    (* let () = print_endline ("some_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [Any [Any 1; Any 2; Any 3]; Any [Any "pretty"; Any true]])))) in *)
    (* let () = print_endline ("some_py_dict: " ^ (get_js_string_from_anything (json_stringify (Any [Any [Any [Any "foo"; Any "bar"]]; Any [Any "pretty"; Any true]])))) in *)
    ()
