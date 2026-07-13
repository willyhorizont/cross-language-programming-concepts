exception Break
exception Continue

let escape_string s =
    if s = "" then ""
    else
        let buf = Buffer.create (String.length s) in
        String.iter (function
            | '\\' -> Buffer.add_string buf "\\\\"
            | '"'  -> Buffer.add_string buf "\\\""
            | '\n' -> Buffer.add_string buf "\\n"
            | '\r' -> Buffer.add_string buf "\\r"
            | '\t' -> Buffer.add_string buf "\\t"
            | c    -> Buffer.add_char buf c
        ) s;
        Buffer.contents buf

type xl =
    | None
    | Bool of bool
    | String of string
    | Int of int
    | Float of float
    | List of xl list
    | Dict of (string, xl) Hashtbl.t
    | Closure of (xl -> xl)

let to_none = function | None -> () | _ -> ()
let to_bool = function | Bool v -> v | _ -> false
let to_string = function | String v -> v | _ -> ""
let to_int = function | Int v -> v | _ -> 0
let to_float = function | Float v -> v | _ -> 0.0
let to_list = function | List v -> v | _ -> []
let to_dict = function | Dict v -> v | _ -> Hashtbl.create 1
let to_closure = function | Closure v -> v | _ -> (fun x -> x)

let iter (va : xl) : (unit -> xl option) =
    Seq.to_dispenser (List.to_seq (to_list va))

let next = (fun itr -> (
    match itr () with
    | Some v -> v
    | None -> None
))

let call (f : xl) (va : xl list) : xl =
    match f with
    | Closure fn -> fn (List va)
    | _ -> None

let none = None
let bool (v : bool) : xl = Bool v
let string (v : string) : xl = String v
let int (v : int) : xl = Int v
let float (v : float) : xl = Float v
let list (v : xl list) : xl = List v
let dict (p : (string * xl) list) : xl =
    let len = match List.length p with | 0 -> 1 | n -> n in
    let d = Hashtbl.create len in
    List.iter (fun (k, v) -> Hashtbl.add d k v) p;
    Dict d
let closure (v : xl -> xl) : xl = Closure v

let is_none = function | None -> true | _ -> false
let is_bool = function | Bool _ -> true | _ -> false
let is_string = function | String _ -> true | _ -> false
let is_int = function | Int _ -> true | _ -> false
let is_float = function | Float _ -> true | _ -> false
let is_list = function | List _ -> true | _ -> false
let is_dict = function | Dict _ -> true | _ -> false
let is_closure = function | Closure _ -> true | _ -> false

let append = (fun va -> (
    let itr = iter va in
    let l = next itr in
    let le = next itr in
    List (to_list l @ [le])
))

let pop = (fun va -> (
    let itr = iter va in
    let l = next itr in
    match List.rev (to_list l) with
    | [] -> failwith "NotError: Just list pop sentinel value"
    | lt :: lrev -> (List (List.rev lrev), lt)
))

let find = (fun va -> (
    let itr = iter va in
    let l = next itr in
    let c = next itr in
    let n = ref None in
    let i = ref (Int 0) in
    try
        List.iter (fun el -> (
            match c with
            | Closure f ->
                if (to_bool (f (List [el; !i; l]))) then begin
                    n := el;
                    raise Break
                end;
                i := Int ((to_int !i) + 1)
            | _ -> ()
        )) (to_list l);
        None
    with Break -> !n
))

let get = (fun va -> (
    let itr = iter va in
    let d = next itr in
    let k = next itr in
    try
        match Hashtbl.find_opt (to_dict d) (to_string k) with
        | Some v -> v
        | None -> None
    with _ -> None
))

let string_repeat = (fun va -> (
    let itr = iter va in
    let s = next itr in
    let n = next itr in
    String (String.concat "" (List.init (to_int n) (fun _ -> (to_string s))))
))

let json_stringify (va : xl list) : string =
    let itr = Seq.to_dispenser (List.to_seq va) in
    let a = next itr in
    let o = next itr in
    let p = ref false in
    if not (is_none o) then begin
        p := to_bool (get (List [o; String "pretty"]))
    end;
    let t = string_repeat (List [String " "; Int 4]) in
    let s = ref [dict [("t", String "v"); ("v", a); ("d", Int 0)]] in
    let r = ref "" in
    while List.length !s > 0 do
        try
            let (lrest, c) = pop (List [List !s]) in
            s := to_list lrest;
            if ((to_string (get (List [c; String "t"]))) = "r") then begin
                r := !r ^ (to_string (get (List [c; String "v"])));
                raise Continue
            end;
            let v = get (List [c; String "v"]) in
            let cur_d = get (List [c; String "d"]) in
            if (is_none v) then begin
                r := !r ^ "null";
                raise Continue
            end;
            if (is_bool v) then begin
                r := !r ^ (string_of_bool (to_bool v));
                raise Continue
            end;
            if (is_string v) then begin
                r := !r ^ "\"" ^ (escape_string (to_string v)) ^ "\"";
                raise Continue
            end;
            if (is_int v) then begin
                r := !r ^ (string_of_int (to_int v));
                raise Continue
            end;
            if (is_float v) then begin
                r := !r ^ (string_of_float (to_float v));
                raise Continue
            end;
            if (is_closure v) then begin
                r := !r ^ "\"[object Function]\"";
                raise Continue
            end;
            if (is_list v) then begin
                let lv = to_list v in
                if List.length lv = 0 then begin
                    r := !r ^ "[]";
                    raise Continue
                end;
                let child_d = Int ((to_int cur_d) + 1) in
                s := to_list (append (List [List !s; dict [
                    ("t", String "r");
                    ("v", (if !p then String ("\n" ^ (to_string (string_repeat (List [t; cur_d]))) ^ "]") else String "]"));
                    ("d", cur_d)
                ]]));
                for i = (List.length lv - 1) downto 0 do
                    s := to_list (append (List [List !s; dict [
                        ("t", String "v");
                        ("v", (List.nth lv i));
                        ("d", child_d)
                    ]]));
                    if i > 0 then begin
                        s := to_list (append (List [List !s; dict [
                            ("t", String "r");
                            ("v", (if !p then String (",\n" ^ (to_string (string_repeat (List [t; child_d])))) else String ", "));
                            ("d", child_d)
                        ]]));
                    end;
                done;
                s := to_list (append (List [List !s; dict [
                    ("t", String "r");
                    ("v", (if !p then String ("[\n" ^ (to_string (string_repeat (List [t; child_d])))) else String "["));
                    ("d", cur_d)
                ]]));
                raise Continue
            end;
            if (is_dict v) then begin
                let dv = to_dict v in
                if Hashtbl.length dv = 0 then begin
                    r := !r ^ "{}";
                    raise Continue
                end;
                let dpl = Hashtbl.fold (fun k v acc -> (k, v) :: acc) dv [] in
                let child_d = Int ((to_int cur_d) + 1) in
                s := to_list (append (List [List !s; dict [
                    ("t", String "r");
                    ("v", (if !p then String ("\n" ^ (to_string (string_repeat (List [t; cur_d]))) ^ "}") else String "}"));
                    ("d", cur_d)
                ]]));
                for i = (List.length dpl - 1) downto 0 do
                    let (dk, dv) = List.nth dpl i in
                    s := to_list (append (List [List !s; dict [
                        ("t", String "v");
                        ("v", dv);
                        ("d", child_d)
                    ]]));
                    s := to_list (append (List [List !s; dict [
                        ("t", String "r");
                        ("v", String ("\"" ^ dk ^ "\": "));
                        ("d", child_d)
                    ]]));
                    if i > 0 then begin
                        s := to_list (append (List [List !s; dict [
                            ("t", String "r");
                            ("v", (if !p then String (",\n" ^ (to_string (string_repeat (List [t; child_d])))) else String ", "));
                            ("d", child_d)
                        ]]));
                    end;
                done;
                s := to_list (append (List [List !s; dict [
                    ("t", String "r");
                    ("v", (if !p then String ("{\n" ^ (to_string (string_repeat (List [t; child_d])))) else String "{"));
                    ("d", cur_d)
                ]]));
                raise Continue
            end;
            r := !r ^ "\"[object Ocaml Object]\"";
        with Continue -> ()
    done;
    !r
