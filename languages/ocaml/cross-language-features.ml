type any =
    | PyNone
    | PyBool of bool
    | JsString of string
    | JsInt of int
    | JsFloat of float
    | PyList of any list
    | PyDict of any list list
    | JsFunction of (any -> any)

let get_type (anything : any) : string =
    match anything with
    | PyNone     -> "PyNone"
    | PyBool _   -> "PyBool"
    | JsString _ -> "JsString"
    | JsInt _    -> "JsInt"
    | JsFloat _  -> "JsFloat"
    | PyList _   -> "PyList"
    | PyDict _   -> "PyDict"
    | JsFunction _   -> "JsFunction"

let json_stringify ?(pretty = true) (anything : any) : string =
    let rec stringify_cps (item : any) (depth : int) (k : string -> string) : string =
        let indent d = if pretty then String.make (d * 4) ' ' else "" in
        let newline = if pretty then "\n" else "" in
        match item with
        | PyNone -> k "PyNone"
        | PyBool any_bool -> k (string_of_bool any_bool)
        | JsString any_string -> k ("\"" ^ any_string ^ "\"")
        | JsInt any_int -> k (string_of_int any_int)
        | JsFloat any_float -> k (string_of_float any_float)
        | PyList any_list ->
            let rec loop_list (acc : string list) (remaining : any list) (k_list : string -> string) =
                match remaining with
                | [] -> 
                    let current_indent = indent depth in
                    let inner_indent = indent (depth + 1) in
                    let joined = 
                        if remaining = any_list && acc = [] then "[]"
                        else
                            "[" ^ newline ^ 
                            (String.concat (";" ^ newline) (List.rev_map (fun s -> inner_indent ^ s) acc)) ^ 
                            newline ^ current_indent ^ "]"
                    in
                    k_list joined
                | head :: tail ->
                    stringify_cps head (depth + 1) (fun res ->
                        loop_list (res :: acc) tail k_list
                    )
            in
            loop_list [] any_list k
        | PyDict any_dict ->
            let rec loop_dict (acc : string list) (remaining : any list list) (k_dict : string -> string) =
                match remaining with
                | [] -> 
                    let current_indent = indent depth in
                    let inner_indent = indent (depth + 1) in
                    let joined = 
                        if remaining = any_dict && acc = [] then "{}"
                        else
                            "{" ^ newline ^ 
                            (String.concat ("," ^ newline) (List.rev_map (fun s -> inner_indent ^ s) acc)) ^ 
                            newline ^ current_indent ^ "}"
                    in
                    k_dict joined
                | head :: tail ->
                    stringify_cps (PyList head) (depth + 1) (fun res ->
                        loop_dict (res :: acc) tail k_dict
                    )
            in
            loop_dict [] any_dict k
        | JsFunction _ -> k "<function>"
    in
    stringify_cps anything 0 (fun x -> x)

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
        PyNone;
        PyBool true;
        PyBool false;
        JsString "foo";
        JsInt (123);
        JsInt (-123);
        JsFloat (123.789);
        JsFloat (-123.789);
        PyList [JsInt 1; JsInt 2; JsInt 3];
        PyDict [[JsString "foo"; JsString "bar"]];
        JsFunction (fun variadic_arguments -> (
            match variadic_arguments with 
            | PyList [JsInt a; JsInt b] -> JsInt (a * b) 
            | _ -> PyNone
        ))
    ]
    in
    let () = 
        print_endline ("some_python_like_list: " ^ json_stringify (PyList some_python_like_list))
    in
    let () = 
        print_endline ("some_python_like_list: " ^ json_stringify ~pretty:false (PyList some_python_like_list))
    in
    let some_py_dict = [
        [JsString "some_py_none"; PyNone];
        [JsString "some_py_boolean_true"; PyBool true];
        [JsString "some_py_boolean_false"; PyBool false];
        [JsString "some_js_string"; JsString "foo"];
        [JsString "some_js_int_positive"; JsInt (123)];
        [JsString "some_js_int_negative"; JsInt (-123)];
        [JsString "some_js_float_positive"; JsFloat (123.789)];
        [JsString "some_js_float_negative"; JsFloat (-123.789)];
        [JsString "some_py_list"; PyList [JsInt 1; JsInt 2; JsInt 3]];
        [JsString "some_py_dict"; PyDict [[JsString "foo"; JsString "bar"]]];
        [JsString "some_js_function"; JsFunction (fun variadic_arguments -> (
            match variadic_arguments with 
            | PyList [JsInt a; JsInt b] -> JsInt (a * b) 
            | _ -> PyNone
        ))]
    ]
    in
    let () = 
        print_endline ("some_py_dict: " ^ json_stringify (PyDict some_py_dict))
    in
    let () = 
        print_endline ("some_py_dict: " ^ json_stringify ~pretty:false (PyDict some_py_dict))
    in
    (* List.iter (fun item -> 
        print_endline ("get_type item: " ^ get_type item)
    ) some_python_like_list *)
    ()
