type any = Any : 't -> any

type py_none = unit
type py_bool = bool
type js_string = string
type js_int = int
type js_float = float
type py_list = any list
type py_dict = py_list list
type js_function = any -> any

let parse_ocaml_value = (fun anything -> ((Obj.magic anything) : Obj.t))

let parse_py_none = (fun anything -> ((Obj.magic anything) : py_none))
let parse_py_bool = (fun anything -> ((Obj.magic anything) : py_bool))
let parse_js_string = (fun anything -> ((Obj.magic anything) : js_string))
let parse_js_int = (fun anything -> ((Obj.magic anything) : js_int))
let parse_js_float = (fun anything -> ((Obj.magic anything) : js_float))
let parse_py_list = (fun anything -> ((Obj.magic anything) : py_list))
let parse_py_dict = (fun anything -> ((Obj.magic anything) : py_dict))
let parse_js_function = (fun anything -> ((Obj.magic anything) : js_function))

let get_is_py_none = (fun anything -> ((not (Obj.is_block anything)) && ((parse_js_int anything) = 0)))
let get_is_py_bool = (fun anything -> ((not (Obj.is_block anything)) && ((fun v -> (v = 0 || v = 1))(parse_js_int anything))))
let get_is_js_string = (fun anything -> ((Obj.is_block anything) && ((Obj.tag anything) = Obj.string_tag)))
let get_is_js_int = (fun anything -> (not (Obj.is_block anything)))
let get_is_js_float = (fun anything -> ((Obj.is_block anything) && ((Obj.tag anything) = Obj.double_tag)))
let get_is_py_list = (fun anything -> ((Obj.is_block anything) && ((Obj.tag anything) = 0)))

let find_item_in_py_list = (fun any_py_list -> (
    try
        let v = List.find (fun x -> x mod 2 = 0) (parse_py_list any_py_list) in
        print_endline ("Ketemu: " ^ string_of_int v)
    with Not_found ->
        print_endline "Tidak ditemukan"
))

let get_py_dict_entry = (fun dict_item -> (
    let ocaml_dict_entry = (parse_ocaml_value dict_item)
    in
    if (Obj.is_block ocaml_dict_entry) then
        if (Obj.tag ocaml_dict_entry = 0) then
            match (parse_py_list ocaml_dict_entry) with
            | [Any key; Any value] ->
                if (get_is_js_string (parse_ocaml_value key)) then
                    [Any key; Any value]
                else
                    failwith "Error: can not get py_dict entry"
            | _ -> 
                failwith "Error: can not get py_dict entry"
        else
            failwith "Error: can not get py_dict entry"
))

let get_py_dict_property = (fun any_dict any_key -> (
    let target_key = parse_js_string (parse_ocaml_value any_key) in
    match any_dict with
    | Any nested_list ->
        (* 2. Ekstrak key yang dicari menjadi string biasa *)
        
        (* 3. Fungsi rekursif untuk mencari pasangan [key; value] *)
        let rec find_value list_data =
            match list_data with
            | [] -> failwith ("Key Error: " ^ target_key ^ " not found")
            | entry :: tail ->
                match parse_py_list (parse_ocaml_value entry) with
                | [Any k; Any v] ->
                    let current_key = parse_js_string (parse_ocaml_value k) in
                    if current_key = target_key then 
                        Any v (* Kembalikan dalam bentuk Any *)
                    else 
                        find_value tail
                | _ -> failwith "Error: Invalid dictionary entry format"
        in
        find_value nested_list
))

let get_is_py_dict = (fun anything -> (
    if (get_is_py_list anything) then
        let list_item = (parse_py_list anything)
        in
        if List.length list_item = 0 then
            false
        else if List.length list_item > 0 then
            List.for_all (fun dict_item -> (
                let ocaml_dict_entry = (parse_ocaml_value dict_item)
                in
                if (not (Obj.is_block ocaml_dict_entry)) then 
                    ((parse_js_int ocaml_dict_entry) = 0)
                else 
                    if (Obj.tag ocaml_dict_entry = 0) then
                        match (parse_py_list ocaml_dict_entry) with
                        | [Any key; Any value] ->
                            if (get_is_js_string (parse_ocaml_value key)) then
                                true
                            else
                                false
                        | _ -> 
                            false
                    else
                        false
            )) list_item
        else
            false
    else
        false
))
let get_is_js_function = (fun anything -> ((Obj.is_block anything) && ((Obj.tag anything) = Obj.closure_tag)))

let get_type = (fun anything -> (
    if (get_is_py_none anything) then
        "py_none"
    else if (get_is_py_bool anything) then
        "py_bool"
    else if (get_is_js_string anything) then
        "js_string"
    else if (get_is_js_int anything) then
        "js_int"
    else if (get_is_js_float anything) then
        "js_float"
    else if (get_is_py_list anything) then
        "py_list"
    else if (get_is_py_dict anything) then
        "py_dict"
    else if (get_is_js_function anything) then
        "js_function"
    else
        "ocaml_value"
))

let get_py_list_variadic_arguments = (fun anything -> (
    let ocaml_variadic_arguments = (parse_ocaml_value anything)
    in
    if (get_is_py_list ocaml_variadic_arguments) then
        ocaml_variadic_arguments
    else
        failwith "Error: can not parse argument to py_list"
))

type token_type = Raw | Value

type token_stack_type = {
    token_type: token_type;
    token_ocaml_value: Obj.t;
    token_string_value: string;
    indentation_level: int;
}

let string_repeat = (fun any_js_string any_js_int -> (
    Any (String.concat "" (List.init parse_js_int (parse_ocaml_value any_js_int) (fun _ -> parse_js_string (parse_ocaml_value any_js_string))))
))

let py_list_insert_tail = (fun list_ref something -> (list_ref @ [Any something]))
let py_list_remove_tail = (fun list_ref -> (
    match List.rev list_ref with
    | [] -> failwith "Error: list empty"
    | list_tail :: rest_reversed ->
        let list_no_tail = List.rev rest_reversed in
        (list_no_tail, list_tail)
))

let json_stringify = (fun (anything) ?(pretty = false) () -> (
    let indentation = string_repeat (Any " ") (Any 4)
    in
    let token_stack_ref = ref [[Any "type"; Any "value"]; [Any "value"; Any anything]; [Any "indentation_level"; Any 0]]
    in
    let result_ref = ref ""
    in

    while List.length !token_stack_ref > 0 do
        let (list_no_tail, list_tail) = py_list_remove_tail token_stack_ref
        in
        token_stack_ref := list_no_tail;

        if list_tail.token_type = Raw then
        result_ref := !result_ref ^ list_tail.token_string_value
        else
        let current_indentation_level = list_tail.indentation_level in
        let current_value_type = get_type list_tail.token_ocaml_value in
        
        if current_value_type = "py_none" then
            result_ref := !result_ref ^ "null"
            
        else if current_value_type = "js_string" then
            let s = parse_js_string list_tail.token_ocaml_value in
            result_ref := !result_ref ^ "\"" ^ s ^ "\""
            
        else if current_value_type = "js_int" then
            let i = parse_js_int list_tail.token_ocaml_value in
            result_ref := !result_ref ^ string_of_int i
            
        else if current_value_type = "js_float" then
            let f = parse_js_float list_tail.token_ocaml_value in
            result_ref := !result_ref ^ string_of_float f
            
        else if current_value_type = "py_bool" then
            let b = parse_py_bool list_tail.token_ocaml_value in
            result_ref := !result_ref ^ string_of_bool b
            
        else if current_value_type = "py_list" then
            let l = parse_py_list list_tail.token_ocaml_value in
            if l = [] then
            result_ref := !result_ref ^ "[]"
            else
            let child_indentation_level = current_indentation_level + 1 in
            
            let close_val = if pretty then "\n" ^ string_repeat indentation current_indentation_level ^ "]" else "]" in
            token_stack_ref := py_list_insert_tail token_stack_ref { token_type = Raw; token_ocaml_value = (Obj.magic ()); token_string_value = close_val; indentation_level = current_indentation_level };
            
            let arr = Array.of_list l in
            let len = Array.length arr in
            
            for i = len - 1 downto 0 do
                let (Any list_item) = arr.(i) in
                token_stack_ref := py_list_insert_tail token_stack_ref { token_type = Value; token_ocaml_value = parse_ocaml_value list_item; token_string_value = ""; indentation_level = child_indentation_level };
                
                if i > 0 then
                let separator = if pretty then ",\n" ^ string_repeat indentation child_indentation_level else ", " in
                token_stack_ref := py_list_insert_tail token_stack_ref { token_type = Raw; token_ocaml_value = (Obj.magic ()); token_string_value = separator; indentation_level = child_indentation_level }
            done;
            
            let open_val = if pretty then "[\n" ^ string_repeat indentation child_indentation_level else "[" in
            token_stack_ref := py_list_insert_tail token_stack_ref { token_type = Raw; token_ocaml_value = (Obj.magic ()); token_string_value = open_val; indentation_level = child_indentation_level }

        else if current_value_type = "py_dict" then
            let d = parse_py_dict list_tail.token_ocaml_value in
            if d = [] then
            result_ref := !result_ref ^ "{}"
            else
            let child_indentation_level = current_indentation_level + 1 in
            
            let close_val = if pretty then "\n" ^ string_repeat indentation current_indentation_level ^ "}" else "}" in
            token_stack_ref := py_list_insert_tail token_stack_ref { token_type = Raw; token_ocaml_value = (Obj.magic ()); token_string_value = close_val; indentation_level = current_indentation_level };
            
            let arr = Array.of_list d in
            let len = Array.length arr in
            
            for i = len - 1 downto 0 do
                let (Any dict_item) = arr.(i) in
                let pair = parse_py_list (parse_ocaml_value dict_item) in
                
                match pair with
                | [Any key_any; Any val_any] ->
                    let key_str = parse_js_string (parse_ocaml_value key_any) in
                    
                    token_stack_ref := py_list_insert_tail token_stack_ref { token_type = Value; token_ocaml_value = parse_ocaml_value val_any; token_string_value = ""; indentation_level = child_indentation_level };
                    token_stack_ref := py_list_insert_tail token_stack_ref { token_type = Raw; token_ocaml_value = (Obj.magic ()); token_string_value = "\"" ^ key_str ^ "\": "; indentation_level = child_indentation_level };
                    
                    if i > 0 then
                    let separator = if pretty then ",\n" ^ string_repeat indentation child_indentation_level else ", " in
                    token_stack_ref := py_list_insert_tail token_stack_ref { token_type = Raw; token_ocaml_value = (Obj.magic ()); token_string_value = separator; indentation_level = child_indentation_level }
                | _ -> ()
            done;
            
            let open_val = if pretty then "{\n" ^ string_repeat indentation child_indentation_level else "{" in
            token_stack_ref := py_list_insert_tail token_stack_ref { token_type = Raw; token_ocaml_value = (Obj.magic ()); token_string_value = open_val; indentation_level = child_indentation_level }
            
        else
            result_ref := !result_ref ^ "\"" ^ current_value_type ^ "\""
    done;
    
    !result_ref
))

let do_nothing = (fun (anything) -> (() : unit))

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
            let variadic_arguments = (get_py_list_variadic_arguments anything)
            in
            match (parse_py_list variadic_arguments) with
            | [Any aa; Any bb] -> Any ((parse_js_int aa) * (parse_js_int bb))
            | _ -> failwith "Error: invalid arguments"
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
            let variadic_arguments = (get_py_list_variadic_arguments anything)
            in
            match (parse_py_list variadic_arguments) with
            | [Any aa; Any bb] -> Any ((parse_js_int aa) * (parse_js_int bb))
            | _ -> failwith "Error: invalid arguments"
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
        do_nothing (Any some_python_like_list)
    in
    let () = 
        do_nothing (Any some_py_dict)
    in
    let () = 
        do_nothing (Any json_stringify)
    in
    (*
    List.iter (fun item -> 
        print_endline ("get_type item: " ^ get_type item)
    ) some_python_like_list
    *)
    ()
