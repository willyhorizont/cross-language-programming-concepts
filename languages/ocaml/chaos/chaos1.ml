type any = Any : 'any_type -> any
type py_none = unit
type py_bool = bool
type js_string = string
type js_int = int
type js_float = float
type py_list = any list
type py_dict = any list list
type js_function = (any -> any)

let do_nothing = (fun (anything : any): unit -> ())

let to_py_none = (fun anything -> ((Obj.magic anything) : py_none))
let to_py_bool = (fun anything -> ((Obj.magic anything) : py_bool))
let to_js_string = (fun anything -> ((Obj.magic anything) : js_string))
let to_js_int = (fun anything -> ((Obj.magic anything) : js_int))
let to_js_float = (fun anything -> ((Obj.magic anything) : js_float))
let to_py_list = (fun anything -> ((Obj.magic anything) : py_list))
let to_py_dict = (fun anything -> ((Obj.magic anything) : py_dict))
let to_js_function = (fun anything -> ((Obj.magic anything) : js_function))

let () =
    let multiply = Any (fun anything -> (
        let variadic_arguments = (Obj.magic anything : Obj.t)
        in
        if (Obj.is_block variadic_arguments) then
            match (to_py_list(variadic_arguments)) with
            | [Any aa; Any bb] -> Any (to_js_int(aa) * to_js_int(bb))
            | _ -> Any ()
        else
            Any ()
    ))
    in
    let some_python_like_list = [
        Any ();
        Any (true);
        Any (false);
        Any ("foo");
        Any (123);
        Any (-123);
        Any (123.789);
        Any (-123.789);
        Any ([Any 1; Any 2; Any 3]);
        Any ([[Any "foo"; Any "bar"]]);
        Any (fun anything -> (
            let variadic_arguments = (Obj.magic anything : Obj.t)
            in
            if (Obj.is_block variadic_arguments) then
                match (to_py_list(variadic_arguments)) with
                | [Any aa; Any bb] -> Any (to_js_int(aa) * to_js_int(bb))
                | _ -> Any ()
            else
                Any ()
        ))
    ]
    in
    let () = 
        do_nothing (Any multiply)
    in
    let () = 
        do_nothing (Any some_python_like_list)
    in
    ()
