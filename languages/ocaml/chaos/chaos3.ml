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

let do_nothing = (fun anything -> (() : unit))

let () =
    let multiply = Any (fun anything -> (
        let variadic_arguments = (get_py_list_variadic_arguments anything)
        in
        match (parse_py_list variadic_arguments) with
        | [Any aa; Any bb] -> Any ((parse_js_int aa) * (parse_js_int bb))
        | _ -> failwith "Error: invalid arguments"
    ))
    in
    let () = 
        do_nothing (Any multiply)
    in
    ()
