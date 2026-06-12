open Willyhorizont.Runtime

let () =
    let say_hello = (fun (callback_function) -> (
        print_endline "hello";
        callback_function ()
    )) in
    let () = say_hello (fun () -> (
        print_endline "world"
    )) in
    let some_py_list = Any [
        Any ();
        Any true;
        Any false;
        Any "foo";
        Any ((123));
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
        ))
    ] in
    (*
    let () = print_endline ("some_py_list: " ^ json_stringify (PyList some_py_list)) in
    let () = print_endline ("some_py_list: " ^ json_stringify ~pretty:false (PyList some_py_list)) in
    *)
    let some_py_dict = Any [
        [Any "some_py_none"; Any ()];
        [Any "some_py_boolean_true"; Any true];
        [Any "some_py_boolean_false"; Any false];
        [Any "some_js_string"; Any "foo"];
        [Any "some_js_int_positive"; Any ((123))];
        [Any "some_js_int_negative"; Any (-123)];
        [Any "some_js_float_positive"; Any (123.789)];
        [Any "some_js_float_negative"; Any (-123.789)];
        [Any "some_py_list"; Any [Any 1; Any 2; Any 3]];
        [Any "some_py_dict"; Any [Any [Any "foo"; Any "bar"]]];
        [Any "some_js_function"; Any (fun any_variadic_arguments_py_list -> (
            let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
            let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
            let aa = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
            let bb = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
            Any ((get_js_int_from_anything aa) * (get_js_int_from_anything bb))
        ))]
    ] in
    (*
    let () = print_endline ("some_py_dict: " ^ json_stringify (PyDict some_py_dict)) in
    let () = print_endline ("some_py_dict: " ^ json_stringify ~pretty:false (PyDict some_py_dict)) in
    *)
    let () = do_nothing (some_py_list) in
    let () = do_nothing (some_py_dict) in
    (* let () = do_nothing (json_stringify (Any [some_py_list; Any [
        [Any "pretty"; Any true]
    ]])) in
    let () = do_nothing (json_stringify (Any [some_py_list])) in *)
    ()
