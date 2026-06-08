type any =
    | Null
    | Bool of bool
    | String of string
    | Int of int
    | Float of float
    | List of any list
    | Dict of any list list
    | Func of (any -> any)

let json_stringify ?(pretty = true) (anything : any) : string =
    let rec stringify_cps (item : any) (depth : int) (k : string -> string) : string =
        let indent d = if pretty then String.make (d * 4) ' ' else "" in
        let newline = if pretty then "\n" else "" in
        match item with
            | Null -> k "Null"
            | Bool any_bool -> k (string_of_bool any_bool)
            | String any_string -> k ("\"" ^ any_string ^ "\"")
            | Int any_int -> k (string_of_int any_int)
            | Float any_float -> k (string_of_float any_float)
            | List any_list ->
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
            | Dict any_dict ->
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
                        stringify_cps (List head) (depth + 1) (fun res ->
                            loop_dict (res :: acc) tail k_dict
                        )
                in
                loop_dict [] any_dict k
            | Func _ -> k "<function>"
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
        Null;
        Bool true;
        Bool false;
        String "foo";
        Int 123;
        Int (-123);
        Float 123.789;
        Float (-123.789);
        List [Int 1; Int 2; Int 3];
        Dict [[String "foo"; String "bar"]];
        Func (fun variadic_arguments -> (
            match variadic_arguments with 
                | List [Int a; Int b] -> Int (a * b) 
                | _ -> Null
        ))
    ]
    in
    let () = 
        print_endline ("some_python_like_list: " ^ json_stringify (List some_python_like_list))
    in
    let () = 
        print_endline ("some_python_like_list: " ^ json_stringify ~pretty:false (List some_python_like_list))
    in
    let some_python_like_dict = [
        [String "some_null"; Null];
        [String "some_boolean_true"; Bool true];
        [String "some_boolean_false"; Bool false];
        [String "some_string"; String "foo"];
        [String "some_int_positive"; Int 123];
        [String "some_int_negative"; Int (-123)];
        [String "some_float_positive"; Float 123.789];
        [String "some_float_negative"; Float (-123.789)];
        [String "some_python_like_list"; List [Int 1; Int 2; Int 3]];
        [String "some_python_like_dict"; Dict [[String "foo"; String "bar"]]];
        [String "some_function"; Func (fun variadic_arguments -> (
            match variadic_arguments with 
                | List [Int a; Int b] -> Int (a * b) 
                | _ -> Null
        ))]
    ]
    in
    let () = 
        print_endline ("some_python_like_dict: " ^ json_stringify (Dict some_python_like_dict))
    in
    let () = 
        print_endline ("some_python_like_dict: " ^ json_stringify ~pretty:false (Dict some_python_like_dict))
    in
    ()
