module Runtime = struct
    let do_nothing = (fun anything -> (() : unit))

    type any = Any : 't -> any

    type py_none = unit
    type py_bool = bool
    type js_string = string
    type js_int = int
    type js_float = float
    type py_list = any list
    type py_dict = py_list list
    type js_function = any -> any

    type ocaml_primitive =
        | OcamlNone of py_none
        | OcamlBool of py_bool
        | OcamlInt of js_int

    let get_next_item_of_ocaml_py_list_ref = (fun any_py_list_ref -> (
        match !any_py_list_ref with
        | head :: tail -> (
            any_py_list_ref := tail; (* move pointer to next item *)
            head
        )
        | [] -> Any (OcamlNone ())
    ))

    let get_next_item_of_ocaml_generator = (fun any_ocaml_generator -> (
        match any_ocaml_generator () with
        | Some value -> value
        | None -> Any (OcamlNone ())
    ))

    let get_py_none_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : py_none))
    let get_py_bool_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : py_bool))
    let get_js_string_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : js_string))
    let get_js_int_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : js_int))
    let get_js_float_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : js_float))
    let get_py_list_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : py_list))
    let get_py_dict_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : py_dict))
    let get_js_function_from_ocaml_value = (fun (type a) (any_ocaml_value : a) -> (Obj.magic any_ocaml_value : js_function))

    let get_ocaml_value_from_anything = (fun anything -> (Obj.field (Obj.magic anything) 0))

    let get_ocaml_primitive_type_from_anything = (fun anything -> ((Obj.magic (get_ocaml_value_from_anything anything)) : ocaml_primitive))

    let get_py_none_from_anything = (fun anything -> match get_ocaml_primitive_type_from_anything anything with OcamlNone v -> v | _ -> failwith "TypeError: Not py_none")
    let get_py_bool_from_anything = (fun anything -> match get_ocaml_primitive_type_from_anything anything with OcamlBool v -> v | _ -> failwith "TypeError: Not py_bool")
    let get_js_string_from_anything = (fun anything -> ((Obj.magic (get_ocaml_value_from_anything anything)) : js_string))
    let get_js_int_from_anything = (fun anything -> match get_ocaml_primitive_type_from_anything anything with OcamlInt v -> v | _ -> failwith "TypeError: Not js_int")
    let get_js_float_from_anything = (fun anything -> ((Obj.magic (get_ocaml_value_from_anything anything)) : js_float))
    let get_py_list_from_anything = (fun anything -> ((Obj.magic (get_ocaml_value_from_anything anything)) : py_list))
    let get_py_dict_from_anything = (fun anything -> ((Obj.magic (get_ocaml_value_from_anything anything)) : py_dict))
    let get_js_function_from_anything = (fun anything -> ((Obj.magic (get_ocaml_value_from_anything anything)) : js_function))

    let get_is_py_none = (fun anything -> try match get_ocaml_primitive_type_from_anything anything with OcamlNone _ -> true | _ -> false with _ -> false)
    let get_is_py_bool = (fun anything -> try match get_ocaml_primitive_type_from_anything anything with OcamlBool _ -> true | _ -> false with _ -> false)

    let get_is_js_string = (fun anything -> ((fun any_ocaml_value -> ((Obj.is_block any_ocaml_value) && ((Obj.tag any_ocaml_value) = Obj.string_tag))) (get_ocaml_value_from_anything anything)))

    let get_is_js_int = (fun anything -> try match get_ocaml_primitive_type_from_anything anything with OcamlInt _ -> true | _ -> false with _ -> false)

    let get_is_js_float = (fun anything -> ((fun any_ocaml_value -> ((Obj.is_block any_ocaml_value) && ((Obj.tag any_ocaml_value) = Obj.double_tag))) (get_ocaml_value_from_anything anything)))

    let get_is_py_list = (fun anything -> ((fun any_ocaml_value -> ((Obj.is_block any_ocaml_value) && ((Obj.tag any_ocaml_value) = 0))) (get_ocaml_value_from_anything anything)))
    let get_is_js_function = (fun anything -> ((fun any_ocaml_value -> ((Obj.is_block any_ocaml_value) && ((Obj.tag any_ocaml_value) = Obj.closure_tag))) (get_ocaml_value_from_anything anything)))

    let get_is_py_dict = (fun anything -> (
        if (get_is_py_list anything) then
            let any_ocaml_py_dict = (get_py_dict_from_anything anything) in
            if List.length any_ocaml_py_dict = 0 then false
            else (
                List.for_all (fun any_py_dict_item -> (
                    if (get_is_py_list any_py_dict_item) then
                        let any_ocaml_py_dict_entry = (get_py_list_from_anything any_py_dict_item) in
                        match any_ocaml_py_dict_entry with
                        | [any_py_dict_key; any_py_dict_value] -> (get_is_js_string any_py_dict_key)
                        | _ -> false
                    else false
                )) any_ocaml_py_dict
            )
        else false
    ))

    let get_type = (fun anything -> (
        if (get_is_py_none anything) then (Any "py_none")
        else if (get_is_py_bool anything) then (Any "py_bool")
        else if (get_is_js_string anything) then (Any "js_string")
        else if (get_is_js_int anything) then (Any "js_int")
        else if (get_is_js_float anything) then (Any "js_float")
        else if (get_is_py_list anything) then (Any "py_list")
        else if (get_is_py_dict anything) then (Any "py_dict")
        else if (get_is_js_function anything) then (Any "js_function")
        else (Any "ocaml_type")
    ))

    let py_list_insert_tail = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let any_py_list = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let new_py_list_item = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        ((get_py_list_from_anything any_py_list) @ [new_py_list_item])
    ))

    let py_list_remove_tail = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let any_py_list = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        match List.rev (get_py_list_from_anything any_py_list) with
        | [] -> failwith "Error: List empty"
        | list_tail :: rest_reversed -> (List.rev rest_reversed, list_tail)
    ))

    exception Break
    exception Continue

    let get_first_list_item_matching_condition = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let any_py_list = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let callback_function = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let item_found_ref = ref (Any (OcamlNone ())) in
        let any_py_list_item_index_ref = ref (Any (OcamlInt 0)) in
        try
            List.iter (fun any_py_list_item -> (
                if (get_py_bool_from_anything ((get_js_function_from_anything callback_function) (Any (get_py_list_from_ocaml_value [any_py_list_item; !any_py_list_item_index_ref; any_py_list])))) then begin
                    item_found_ref := any_py_list_item;
                    raise Break
                end;
                any_py_list_item_index_ref := Any (OcamlInt ((get_js_int_from_anything !any_py_list_item_index_ref) + 1))
            )) (get_py_list_from_anything any_py_list);
            Any (OcamlNone ())
        with Break -> (
            !item_found_ref
        )
    ))

    let get_py_dict_property = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let any_py_dict = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let any_py_dict_key = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let item_found_ref = ref (Any (OcamlNone ())) in
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
            )) (get_py_dict_from_anything any_py_dict);
            Any (OcamlNone ())
        with Break -> (
            !item_found_ref
        )
    ))

    let string_repeat = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let any_js_string = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let any_js_int = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        Any (String.concat "" (List.init (get_js_int_from_anything any_js_int) (fun _ -> (get_js_string_from_anything any_js_string))))
    ))

    let json_stringify = (fun any_variadic_arguments_py_list -> (
        let ocaml_variadic_arguments = get_py_list_from_anything any_variadic_arguments_py_list in
        let ocaml_variadic_arguments_generator = Seq.to_dispenser (List.to_seq ocaml_variadic_arguments) in
        let anything = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let optionional_argument_py_dict = get_next_item_of_ocaml_generator ocaml_variadic_arguments_generator in
        let pretty_ref = ref (Any (OcamlBool false)) in
        if not (get_is_py_none optionional_argument_py_dict) then begin
            pretty_ref := Any (OcamlBool (get_py_bool_from_anything (get_py_dict_property (Any (get_py_list_from_ocaml_value [optionional_argument_py_dict; Any "pretty"])))))
        end;
        let indentation = string_repeat (Any [Any ""; Any (OcamlInt 4)]) in
        let token_stack = Any [
            Any [
                Any [Any "type"; Any "value"];
                Any [Any "value"; anything];
                Any [Any "indentation_level"; Any (OcamlInt 0)]
            ]
        ] in
        let token_stack_ref = ref (get_py_list_from_anything token_stack) in
        let result_ref = ref (Any "") in

        while List.length !token_stack_ref > 0 do
            try
                let (rest_py_list, current) = py_list_remove_tail (Any [Any !token_stack_ref]) in
                token_stack_ref := rest_py_list;
                let current_value = get_py_dict_property (Any (get_py_list_from_ocaml_value [current; Any "value"])) in
                if ((get_js_string_from_anything (get_py_dict_property (Any (get_py_list_from_ocaml_value [current; Any "type"])))) = "raw") then begin
                    result_ref := Any ((get_js_string_from_anything !result_ref) ^ (get_js_string_from_anything current_value));
                    raise Continue
                end;
                let current_indentation_level = get_py_dict_property (Any (get_py_list_from_ocaml_value [current; Any "indentation_level"])) in
                let current_value_type = get_type current_value in
                if ((get_js_string_from_anything current_value_type) = "py_none") then begin
                    result_ref := Any ((get_js_string_from_anything !result_ref) ^ (get_js_string_from_anything (Any "null")));
                    raise Continue
                end;
                if ((get_js_string_from_anything current_value_type) = "js_string") then begin
                    result_ref := Any ((get_js_string_from_anything !result_ref) ^ (get_js_string_from_anything (Any "\"")) ^ (get_js_string_from_anything current_value) ^ (get_js_string_from_anything (Any "\"")));
                    raise Continue
                end;
                if ((get_js_string_from_anything current_value_type) = "js_int") then begin
                    result_ref := Any ((get_js_string_from_anything !result_ref) ^ (string_of_int (get_js_int_from_anything current_value)));
                    raise Continue
                end;
                if ((get_js_string_from_anything current_value_type) = "js_float") then begin
                    result_ref := Any ((get_js_string_from_anything !result_ref) ^ (string_of_float (get_js_float_from_anything current_value)));
                    raise Continue
                end;
                if ((get_js_string_from_anything current_value_type) = "py_bool") then begin
                    result_ref := Any ((get_js_string_from_anything !result_ref) ^ (string_of_bool (get_py_bool_from_anything current_value)));
                    raise Continue
                end;
                if ((get_js_string_from_anything current_value_type) = "py_list") then begin
                    let current_value_py_list = get_py_list_from_anything current_value in
                    if List.length current_value_py_list = 0 then begin
                        result_ref := Any ((get_js_string_from_anything !result_ref) ^ (get_js_string_from_anything (Any "[]")));
                        raise Continue
                    end;
                    let child_indentation_level = Any (OcamlInt ((get_js_int_from_anything current_indentation_level) + 1)) in
                    token_stack_ref := py_list_insert_tail (Any [Any !token_stack_ref; (Any (get_py_dict_from_ocaml_value [
                        Any [Any "type"; Any "raw"];
                        Any [Any "value"; (if get_py_bool_from_anything !pretty_ref then (Any ((get_js_string_from_anything (Any "\n")) ^ (get_js_string_from_anything (string_repeat (Any [indentation; current_indentation_level]))) ^ (get_js_string_from_anything (Any "]")))) else (Any "]"))];
                        Any [Any "indentation_level"; current_indentation_level]
                    ]))]);
                    for i = (List.length current_value_py_list - 1) downto 0 do
                        token_stack_ref := py_list_insert_tail (Any [Any !token_stack_ref; (Any (get_py_dict_from_ocaml_value [
                            Any [Any "type"; Any "value"];
                            Any [Any "value"; (List.nth current_value_py_list i)];
                            Any [Any "indentation_level"; child_indentation_level]
                        ]))]);
                        if i > 0 then begin
                            token_stack_ref := py_list_insert_tail (Any [Any !token_stack_ref; (Any (get_py_dict_from_ocaml_value [
                                Any [Any "type"; Any "raw"];
                                Any [Any "value"; (if get_py_bool_from_anything !pretty_ref then (Any ((get_js_string_from_anything (Any ",\n")) ^ (get_js_string_from_anything (string_repeat (Any [indentation; child_indentation_level]))))) else (Any ", "))];
                                Any [Any "indentation_level"; child_indentation_level]
                            ]))]);
                        end;
                    done;
                    token_stack_ref := py_list_insert_tail (Any [Any !token_stack_ref; (Any (get_py_dict_from_ocaml_value [
                        Any [Any "type"; Any "raw"];
                        Any [Any "value"; (if get_py_bool_from_anything !pretty_ref then (Any ((get_js_string_from_anything (Any "[\n")) ^ (get_js_string_from_anything (string_repeat (Any [indentation; child_indentation_level]))))) else (Any "["))];
                        Any [Any "indentation_level"; current_indentation_level]
                    ]))]);
                    raise Continue
                end;
                if ((get_js_string_from_anything current_value_type) = "py_dict") then begin
                    let current_value_py_dict_entries = get_py_dict_from_anything current_value in
                    if List.length current_value_py_dict_entries = 0 then begin
                        result_ref := Any ((get_js_string_from_anything !result_ref) ^ (get_js_string_from_anything (Any "{}")));
                        raise Continue
                    end;
                    let child_indentation_level = Any (OcamlInt ((get_js_int_from_anything current_indentation_level) + 1)) in
                    token_stack_ref := py_list_insert_tail (Any [Any !token_stack_ref; (Any (get_py_dict_from_ocaml_value [
                        Any [Any "type"; Any "raw"];
                        Any [Any "value"; (if get_py_bool_from_anything !pretty_ref then (Any ((get_js_string_from_anything (Any "\n")) ^ (get_js_string_from_anything (string_repeat (Any [indentation; current_indentation_level]))) ^ (get_js_string_from_anything (Any "}")))) else (Any "}"))];
                        Any [Any "indentation_level"; current_indentation_level]
                    ]))]);
                    for i = (List.length current_value_py_dict_entries - 1) downto 0 do
                        let any_ocaml_py_dict_entry = (get_py_list_from_anything current_value_py_dict_entries) in
                        let ocaml_py_dict_entry_generator = Seq.to_dispenser (List.to_seq any_ocaml_py_dict_entry) in
                        let any_ocaml_py_dict_key = get_next_item_of_ocaml_generator (ocaml_py_dict_entry_generator) in
                        let any_ocaml_py_dict_value = get_next_item_of_ocaml_generator (ocaml_py_dict_entry_generator) in
                        token_stack_ref := py_list_insert_tail (Any [Any !token_stack_ref; (Any (get_py_dict_from_ocaml_value [
                            Any [Any "type"; Any "value"];
                            Any [Any "value"; any_ocaml_py_dict_value];
                            Any [Any "indentation_level"; child_indentation_level]
                        ]))]);
                        token_stack_ref := py_list_insert_tail (Any [Any !token_stack_ref; (Any (get_py_dict_from_ocaml_value [
                            Any [Any "type"; Any "raw"];
                            Any [Any "value"; Any ((get_js_string_from_anything (Any "\"")) ^ (get_js_string_from_anything any_ocaml_py_dict_key) ^ (get_js_string_from_anything (Any "\": ")))];
                            Any [Any "indentation_level"; child_indentation_level]
                        ]))]);
                        if i > 0 then begin
                            token_stack_ref := py_list_insert_tail (Any [Any !token_stack_ref; (Any (get_py_dict_from_ocaml_value [
                                Any [Any "type"; Any "raw"];
                                Any [Any "value"; (if get_py_bool_from_anything !pretty_ref then (Any ((get_js_string_from_anything (Any ",\n")) ^ (get_js_string_from_anything (string_repeat (Any [indentation; child_indentation_level]))))) else (Any ", "))];
                                Any [Any "indentation_level"; child_indentation_level]
                            ]))]);
                        end;
                    done;
                    token_stack_ref := py_list_insert_tail (Any [Any !token_stack_ref; (Any (get_py_dict_from_ocaml_value [
                        Any [Any "type"; Any "raw"];
                        Any [Any "value"; (if get_py_bool_from_anything !pretty_ref then (Any ((get_js_string_from_anything (Any "[\n")) ^ (get_js_string_from_anything (string_repeat (Any [indentation; child_indentation_level]))))) else (Any "["))];
                        Any [Any "indentation_level"; current_indentation_level]
                    ]))]);
                    raise Continue
                end;
                result_ref := Any ((get_js_string_from_anything !result_ref) ^ (get_js_string_from_anything (Any "\"")) ^ (get_js_string_from_anything current_value_type) ^ (get_js_string_from_anything (Any "\"")));
                ()
            with Continue -> ()
        done;
        !result_ref
    ))
end
