open Willyhorizont.Runtime

let () =
    let say_hello = (fun (callback_function) -> (
        print_endline "hello";
        callback_function ()
    ))
    in
    let () = say_hello (fun () -> (
        print_endline "world"
    ))
    in
    let some_python_like_list = [
        Any ();
        Any true;
        Any false;
        Any "foo";
        Any (123);
        Any (-123);
        Any (123.789);
        Any (-123.789);
        Any [Any 1; Any 2; Any 3];
        Any [[Any "foo"; Any "bar"]];
        Any (fun anything -> (
            let ocaml_variadic_arguments = parse_py_list anything
            in
            let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments)
            in
            let aa = get_next_item_of_generator (ocaml_variadic_arguments_generator)
            in
            let bb = get_next_item_of_generator (ocaml_variadic_arguments_generator)
            in
            Any ((parse_js_int aa) * (parse_js_int bb))
        ))
    ]
    in
    (*
    let () = 
        print_endline ("some_python_like_list: " ^ json_stringify (PyList some_python_like_list))
    in
    let () = 
        print_endline ("some_python_like_list: " ^ json_stringify ~pretty:false (PyList some_python_like_list))
    in
    *)
    let some_py_dict = [
        [Any "some_py_none"; Any ()];
        [Any "some_py_boolean_true"; Any true];
        [Any "some_py_boolean_false"; Any false];
        [Any "some_js_string"; Any "foo"];
        [Any "some_js_int_positive"; Any (123)];
        [Any "some_js_int_negative"; Any (-123)];
        [Any "some_js_float_positive"; Any (123.789)];
        [Any "some_js_float_negative"; Any (-123.789)];
        [Any "some_py_list"; Any [Any 1; Any 2; Any 3]];
        [Any "some_py_dict"; Any [[Any "foo"; Any "bar"]]];
        [Any "some_js_function"; Any (fun anything -> (
            let ocaml_variadic_arguments = parse_py_list anything
            in
            let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments)
            in
            let aa = get_next_item_of_generator (ocaml_variadic_arguments_generator)
            in
            let bb = get_next_item_of_generator (ocaml_variadic_arguments_generator)
            in
            Any ((parse_js_int aa) * (parse_js_int bb))
        ))]
    ]
    in
    (*
    let () = 
        print_endline ("some_py_dict: " ^ json_stringify (PyDict some_py_dict))
    in
    let () = 
        print_endline ("some_py_dict: " ^ json_stringify ~pretty:false (PyDict some_py_dict))
    in
    *)
    let () = 
        do_nothing (some_python_like_list)
    in
    let () = 
        do_nothing (some_py_dict)
    in
    ()
