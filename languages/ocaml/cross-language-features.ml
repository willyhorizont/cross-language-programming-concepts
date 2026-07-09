open Willyhorizont.Runtime

let () =
    (*
    1. support closure as value, or has workaround
    *)
    let say_hello = Any (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let callback_function = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        print_endline "hello";
        (get_js_function_from_anything callback_function) (Any [Any ()])
    )) in
    let _ = Any ((get_js_function_from_anything say_hello) (Any [Any (fun (any_variadic_arguments_py_list) -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        do_nothing ocaml_variadic_arguments_generator;
        print_endline "world";
        Any ()
    ))])) in
    (*
    2. support dynamic-typed value, or has workaround
    *)
    let some_py_list = Any [
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
    let () = print_endline ("some_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [some_py_list])))) in
    let () = print_endline ("some_py_list: " ^ (get_js_string_from_anything (json_stringify (Any [some_py_list; Any [Any [Any "pretty"; Any true]]])))) in
    let some_py_dict = Any [
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
    let () = print_endline ("some_py_dict: " ^ (get_js_string_from_anything (json_stringify (Any [some_py_dict])))) in
    let () = print_endline ("some_py_dict: " ^ (get_js_string_from_anything (json_stringify (Any [some_py_dict; Any [Any [Any "pretty"; Any true]]])))) in
    ()
