module Runtime = struct
    let get_next_item_of_ocaml_py_list_ref = (fun any_ocaml_py_list_ref -> (
        match !any_ocaml_py_list_ref with
        | head :: tail -> 
            any_ocaml_py_list_ref := tail; (* move pointer to next item *)
            head
        | [] -> failwith "Error: No next items"
    ))

    let get_next_item_of_ocaml_generator = (fun any_ocaml_generator -> (
        match any_ocaml_generator () with
        | Some value -> value
        | None -> failwith "Error: No next items"
    ))

    type any = Any : 't -> any

    type py_none = unit
    type py_bool = bool
    type js_string = string
    type js_int = int
    type js_float = float
    type py_list = any list
    type py_dict = py_list list
    type js_function = any -> any

    let parse_ocaml_value = (fun anything -> (Obj.field (Obj.magic anything) 0))

    let get_py_none_from_anything = (fun anything -> ((Obj.magic (parse_ocaml_value anything)) : py_none))
    let get_py_bool_from_anything = (fun anything -> ((Obj.magic (parse_ocaml_value anything)) : py_bool))
    let get_js_string_from_anything = (fun anything -> ((Obj.magic (parse_ocaml_value anything)) : js_string))
    let get_js_int_from_anything = (fun anything -> ((Obj.magic (parse_ocaml_value anything)) : js_int))
    let get_js_float_from_anything = (fun anything -> ((Obj.magic (parse_ocaml_value anything)) : js_float))
    let get_py_list_from_anything = (fun anything -> ((Obj.magic (parse_ocaml_value anything)) : py_list))
    let get_py_dict_from_anything = (fun anything -> ((Obj.magic (parse_ocaml_value anything)) : py_dict))
    let get_js_function_from_anything = (fun anything -> ((Obj.magic (parse_ocaml_value anything)) : js_function))

    let get_py_none_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : py_none))
    let get_py_bool_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : py_bool))
    let get_js_string_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : js_string))
    let get_js_int_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : js_int))
    let get_js_float_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : js_float))
    let get_py_list_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : py_list))
    let get_py_dict_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : py_dict))
    let get_js_function_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : js_function))

    let get_is_py_none = (fun anything -> ((not (Obj.is_block (parse_ocaml_value anything))) && ((get_js_int_from_anything anything) = 0)))
    let get_is_py_bool = (fun anything -> ((not (Obj.is_block (parse_ocaml_value anything))) && (fun v -> (v = 0 || v = 1)) (get_js_int_from_anything anything)))

    let get_is_js_string = (fun anything -> ((fun any_ocaml_value -> ((Obj.is_block any_ocaml_value) && ((Obj.tag any_ocaml_value) = Obj.string_tag))) (parse_ocaml_value anything)))

    let get_is_js_int = (fun anything -> (not (Obj.is_block (parse_ocaml_value anything))))

    let get_is_js_float = (fun anything -> ((fun any_ocaml_value -> ((Obj.is_block any_ocaml_value) && ((Obj.tag any_ocaml_value) = Obj.double_tag))) (parse_ocaml_value anything)))

    let get_is_py_list = (fun anything -> ((fun any_ocaml_value -> ((Obj.is_block any_ocaml_value) && ((Obj.tag any_ocaml_value) = 0))) (parse_ocaml_value anything)))

    let get_is_py_dict = (fun anything -> (
        if (get_is_py_list anything) then
            let any_ocaml_py_list = (get_py_dict_from_anything anything) in
            if List.length any_ocaml_py_list = 0 then
                false
            else if List.length any_ocaml_py_list > 0 then
                List.for_all (fun any_py_list_item -> (
                    if (get_is_py_list any_py_list_item) then
                        let any_ocaml_py_dict_entry = (get_py_list_from_anything any_py_list_item) in
                        if ((List.length any_ocaml_py_dict_entry) = 0) then
                            false
                        else if ((List.length any_ocaml_py_dict_entry) > 0) then
                            match any_ocaml_py_dict_entry with
                            | [any_py_dict_key; any_py_dict_value] ->
                                if (get_is_js_string any_py_dict_key) then
                                    true
                                else
                                    false
                            | _ -> 
                                false
                        else
                            false
                    else
                        false
                )) any_ocaml_py_list
            else
                false
        else
            false
    ))

    let get_is_js_function = (fun anything -> ((fun any_ocaml_value -> ((Obj.is_block any_ocaml_value) && ((Obj.tag any_ocaml_value) = Obj.closure_tag))) (parse_ocaml_value anything)))

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
            "ocaml_type"
    ))

    exception Break

    let get_first_list_item_matching_condition = (fun anything -> (
        let ocaml_variadic_arguments = get_py_list_from_anything anything in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let any_py_list = get_next_item_of_ocaml_generator (ocaml_variadic_arguments_generator) in
        let callback_function = get_next_item_of_ocaml_generator (ocaml_variadic_arguments_generator) in
        let item_found_ref = ref (Any ()) in
        let any_py_list_item_index_ref = ref (Any 0) in
        try
            List.iter (fun any_py_list_item -> (
                if (get_py_bool_from_anything ((get_js_function_from_anything callback_function) (Any (get_py_list_from_ocaml_value [any_py_list_item; !any_py_list_item_index_ref; any_py_list])))) then begin
                    item_found_ref := any_py_list_item;
                    raise Break
                end;
                any_py_list_item_index_ref := Any ((get_js_int_from_anything !any_py_list_item_index_ref) + 1)
            )) (get_py_list_from_anything any_py_list);
            Any ()
        with Break -> (
            !item_found_ref
        )
    ))

    let get_py_dict_property = (fun anything -> (
        let ocaml_variadic_arguments = get_py_list_from_anything anything in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let any_py_dict = get_next_item_of_ocaml_generator (ocaml_variadic_arguments_generator) in
        let any_py_dict_key = get_next_item_of_ocaml_generator (ocaml_variadic_arguments_generator) in
        let item_found_ref = ref (Any ()) in
        try
            List.iter (fun any_py_dict_entry -> (
                let any_ocaml_py_dict_entry = (get_py_list_from_anything any_py_dict_entry) in
                let ocaml_py_dict_entry_generator = Seq.to_dispenser (List.to_seq any_ocaml_py_dict_entry) in
                let any_ocaml_py_dict_key = get_next_item_of_ocaml_generator (ocaml_py_dict_entry_generator) in
                if (get_js_string_from_anything any_ocaml_py_dict_key) = (get_js_string_from_anything any_py_dict_key) then begin
                    let any_ocaml_py_dict_value = get_next_item_of_ocaml_generator (ocaml_py_dict_entry_generator) in
                    item_found_ref := any_ocaml_py_dict_value;
                    raise Break
                end
            )) (get_py_list_from_anything any_py_dict);
            Any ()
        with Break -> (
            !item_found_ref
        )
    ))

    let do_nothing = (fun anything -> (() : unit))
end

    (*
    let get_py_dict_entry = (fun dict_item -> (
        (* TODO *)
        let ocaml_dict_entry = (parse_ocaml_value dict_item)
        in
        if (Obj.is_block ocaml_dict_entry) then
            if (Obj.tag ocaml_dict_entry = 0) then
                match (get_py_list_from_anything ocaml_dict_entry) with
                | [Any key; Any value] ->
                    if (get_is_js_string (parse_ocaml_value key)) then
                        [Any key; Any value]
                    else
                        failwith "Error: Can not get py_dict entry"
                | _ -> 
                    failwith "Error: Can not get py_dict entry"
            else
                failwith "Error: Can not get py_dict entry"
    ))

    (* TODO *)
    type token_type = Raw | Value

    (* TODO *)
    type token_stack_type = {
        token_type: token_type;
        token_ocaml_value: Obj.t;
        token_string_value: string;
        indentation_level: int;
    }

    let string_repeat = (fun any_js_string any_js_int -> (
        (* TODO *)
        Any (String.concat "" (List.init get_js_int_from_anything (parse_ocaml_value any_js_int) (fun _ -> get_js_string_from_anything (parse_ocaml_value any_js_string))))
    ))

    (* TODO *)
    let py_list_insert_tail = (fun list_ref something -> (list_ref @ [Any something]))
    (* TODO *)
    let py_list_remove_tail = (fun list_ref -> (
        match List.rev list_ref with
        | [] -> failwith "Error: List empty"
        | list_tail :: rest_reversed ->
            let list_no_tail = List.rev rest_reversed in
            (list_no_tail, list_tail)
    ))

    let json_stringify = (fun (anything) ?(pretty = false) () -> (
        (* TODO *)
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
                let s = get_js_string_from_anything list_tail.token_ocaml_value in
                result_ref := !result_ref ^ "\"" ^ s ^ "\""
                
            else if current_value_type = "js_int" then
                let i = get_js_int_from_anything list_tail.token_ocaml_value in
                result_ref := !result_ref ^ string_of_int i
                
            else if current_value_type = "js_float" then
                let f = get_js_float_from_anything list_tail.token_ocaml_value in
                result_ref := !result_ref ^ string_of_float f
                
            else if current_value_type = "py_bool" then
                let b = get_py_bool_from_anything list_tail.token_ocaml_value in
                result_ref := !result_ref ^ string_of_bool b
                
            else if current_value_type = "py_list" then
                let l = get_py_list_from_anything list_tail.token_ocaml_value in
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
                let d = get_py_dict_from_anything list_tail.token_ocaml_value in
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
                    let pair = get_py_list_from_anything (parse_ocaml_value dict_item) in
                    
                    match pair with
                    | [Any key_any; Any val_any] ->
                        let key_str = get_js_string_from_anything (parse_ocaml_value key_any) in
                        
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
end *)
