let discard = (fun a -> ())

type xl = Type : 't -> xl
type xl_none = unit
type xl_bool = bool
type xl_string = string
type xl_int = int
type xl_float = float
type xl_list = xl list
type xl_dict = xl_list list
type xl_closure = xl -> xl

let next_el = (fun lr -> (
    match !lr with
    | h :: t -> (
        lr := t;
        h
    )
    | [] -> Type ()
))

let next = (fun itr -> (
    match itr () with
    | Some value -> value
    | None -> Type ()
))

let init_none = (fun (type a) (v : a) -> (Obj.magic v : xl_none))
let init_bool = (fun (type a) (v : a) -> (Obj.magic v : xl_bool))
let init_string = (fun (type a) (v : a) -> (Obj.magic v : xl_string))
let init_int = (fun (type a) (v : a) -> (Obj.magic v : xl_int))
let init_float = (fun (type a) (v : a) -> (Obj.magic v : xl_float))
let init_list = (fun (type a) (v : a) -> (Obj.magic v : xl_list))
let init_dict = (fun (type a) (v : a) -> (Obj.magic v : xl_dict))
let init_closure = (fun (type a) (v : a) -> (Obj.magic v : xl_closure))

let to_native = (fun a -> (Obj.field (Obj.magic a) 0))

let to_none = (fun a -> ((Obj.magic (to_native a)) : xl_none))
let to_bool = (fun a -> ((Obj.magic (to_native a)) : xl_bool))
let to_string = (fun a -> ((Obj.magic (to_native a)) : xl_string))
let to_int = (fun a -> ((Obj.magic (to_native a)) : xl_int))
let to_float = (fun a -> ((Obj.magic (to_native a)) : xl_float))
let to_list = (fun a -> ((Obj.magic (to_native a)) : xl_list))
let to_dict = (fun a -> ((Obj.magic (to_native a)) : xl_dict))
let to_closure = (fun a -> ((Obj.magic (to_native a)) : xl_closure))

let none_to_string = (fun any_py_none -> ("None"))

let is_none = (fun a -> ((not (Obj.is_block (to_native a))) && ((to_int a) = 0) && ((to_bool a) = false) && ((string_of_bool (to_bool a)) = "false") && ((to_none (a)) = ())))
let is_bool = (fun a -> ((not (Obj.is_block (to_native a))) && ((to_int a) = 1) && ((to_bool a) = true) && ((string_of_bool (to_bool a)) = "true")))
let is_string = (fun a -> ((fun v -> ((Obj.is_block v) && ((Obj.tag v) = Obj.string_tag))) (to_native a)))
let is_int = (fun a -> ((not (Obj.is_block (to_native a))) && ((to_int a) <> 0)))
let is_float = (fun a -> ((fun v -> ((Obj.is_block v) && ((Obj.tag v) = Obj.double_tag))) (to_native a)))
let is_list = (fun a -> ((fun v -> ((Obj.is_block v) && ((Obj.tag v) = 0))) (to_native a)))

let is_dict = (fun a -> (
    if (is_list a) then
        let d = (to_dict a) in
        if List.length d = 0 then false
        else (
            List.for_all (fun dpl -> (
                if (is_list dpl) then
                    let dpv = (to_list dpl) in
                    match dpv with
                    | [dk; dv] -> (is_string dk)
                    | _ -> false
                else false
            )) d
        )
    else false
))

let is_closure = (fun a -> ((fun v -> ((Obj.is_block v) && ((Obj.tag v) = Obj.closure_tag))) (to_native a)))

let get_type = (fun a -> (
    if (is_int a) then (Type "[object XlInt]")
    else
    if (is_bool a) then (Type "[object XlBool]")
    else
    if (is_none a) then (Type "[object XlNone]")
    else
    if (is_string a) then (Type "[object XlString]")
    else
    if (is_float a) then (Type "[object XlFloat]")
    else
    if (is_dict a) then (Type "[objecr XlDict]")
    else
    if (is_list a) then (Type "[objecr XlList]")
    else
    if (is_closure a) then (Type "[objecr XlClosure]")
    else (Type "[objecr Ocaml Object]")
))

let append = (fun va -> (
    let itr = Seq.to_dispenser (List.to_seq (to_list va)) in
    let l = next itr in
    let le = next itr in
    ((to_list l) @ [le])
))

let pop = (fun va -> (
    let itr = Seq.to_dispenser (List.to_seq (to_list va)) in
    let l = next itr in
    match List.rev (to_list l) with
    | [] -> failwith "Error: List empty"
    | lt :: lrev -> (List.rev lrev, lt)
))

exception Break
exception Continue

let find = (fun va -> (
    let itr = Seq.to_dispenser (List.to_seq (to_list va)) in
    let l = next itr in
    let c = next itr in
    let n = ref (Type ()) in
    let i = ref (Type 0) in
    try
        List.iter (fun el -> (
            if (to_bool ((to_closure c) (Type (init_list [el; !i; l])))) then begin
                n := el;
                raise Break
            end;
            i := Type ((to_int !i) + 1)
        )) (to_list l);
        Type ()
    with Break -> (
        !n
    )
))

let get = (fun va -> (
    let itr = Seq.to_dispenser (List.to_seq (to_list va)) in
    let d = next itr in
    let k = next itr in
    let el = ref (Type ()) in
    try
        List.iter (fun de -> (
            let itr = Seq.to_dispenser (List.to_seq (to_list de)) in
            let dk = next (itr) in
            if (to_string dk) = (to_string k) then begin
                let dv = next (itr) in
                el := dv;
                raise Break
            end
        )) (to_dict d);
        Type ()
    with Break -> (
        !el
    )
))

let string_repeat = (fun va -> (
    let itr = Seq.to_dispenser (List.to_seq (to_list va)) in
    let s = next itr in
    let n = next itr in
    Type (String.concat "" (List.init (to_int n) (fun _ -> (to_string s))))
))

let json_stringify = (fun va -> (
    let itr = Seq.to_dispenser (List.to_seq (to_list va)) in
    let a = next itr in
    let o = next itr in
    let p = ref (Type false) in
    if not (is_none o) then begin
        p := Type (to_bool (get (Type (init_list [o; Type "pretty"]))))
    end;
    let t = string_repeat (Type [Type " "; Type 4]) in
    let s = ref (to_list (Type [
        Type [
            Type [Type "t"; Type "v"];
            Type [Type "v"; a];
            Type [Type "d"; Type 0]
        ]
    ])) in
    let r = ref (Type "") in

    while List.length !s > 0 do
        try
            let (lrest, c) = pop (Type [Type !s]) in
            s := lrest;
            let v = get (Type (init_list [c; Type "v"])) in
            if ((to_string (get (Type (init_list [c; Type "t"])))) = "r") then begin
                r := Type ((to_string !r) ^ (to_string v));
                raise Continue
            end;
            let cur_d = get (Type (init_list [c; Type "d"])) in
            let cur_t = get_type v in
            if ((to_string cur_t) = "[object XlInt]") then begin
                r := Type ((to_string !r) ^ (string_of_int (to_int v)));
                raise Continue
            end;
            if ((to_string cur_t) = "[object XlBool]") then begin
                r := Type ((to_string !r) ^ (string_of_bool (to_bool v)));
                raise Continue
            end;
            if ((to_string cur_t) = "[object XlNone]") then begin
                r := Type ((to_string !r) ^ (string_of_int (to_int (Type 0))));
                raise Continue
            end;
            if ((to_string cur_t) = "[object XlString]") then begin
                r := Type ((to_string !r) ^ (to_string (Type "\"")) ^ (to_string v) ^ (to_string (Type "\"")));
                raise Continue
            end;
            if ((to_string cur_t) = "[object XlFloat]") then begin
                r := Type ((to_string !r) ^ (string_of_float (to_float v)));
                raise Continue
            end;
            if ((to_string cur_t) = "[objecr XlList]") then begin
                let l = to_list v in
                if List.length l = 0 then begin
                    r := Type ((to_string !r) ^ (to_string (Type "[]")));
                    raise Continue
                end;
                let child_d = Type ((to_int cur_d) + 1) in
                s := append (Type [Type !s; (Type (init_dict [
                    Type [Type "t"; Type "r"];
                    Type [Type "v"; (if to_bool !p then (Type ((to_string (Type "\n")) ^ (to_string (string_repeat (Type [t; cur_d]))) ^ (to_string (Type "]")))) else (Type "]"))];
                    Type [Type "d"; cur_d]
                ]))]);
                for i = (List.length l - 1) downto 0 do
                    s := append (Type [Type !s; (Type (init_dict [
                        Type [Type "t"; Type "v"];
                        Type [Type "v"; (List.nth l i)];
                        Type [Type "d"; child_d]
                    ]))]);
                    if i > 0 then begin
                        s := append (Type [Type !s; (Type (init_dict [
                            Type [Type "t"; Type "r"];
                            Type [Type "v"; (if to_bool !p then (Type ((to_string (Type ",\n")) ^ (to_string (string_repeat (Type [t; child_d]))))) else (Type ", "))];
                            Type [Type "d"; child_d]
                        ]))]);
                    end;
                done;
                s := append (Type [Type !s; (Type (init_dict [
                    Type [Type "t"; Type "r"];
                    Type [Type "v"; (if to_bool !p then (Type ((to_string (Type "[\n")) ^ (to_string (string_repeat (Type [t; child_d]))))) else (Type "["))];
                    Type [Type "d"; cur_d]
                ]))]);
                raise Continue
            end;
            if ((to_string cur_t) = "[objecr XlDict]") then begin
                let de = to_dict v in
                if List.length de = 0 then begin
                    r := Type ((to_string !r) ^ (to_string (Type "{}")));
                    raise Continue
                end;
                let child_d = Type ((to_int cur_d) + 1) in
                s := append (Type [Type !s; (Type (init_dict [
                    Type [Type "t"; Type "r"];
                    Type [Type "v"; (if to_bool !p then (Type ((to_string (Type "\n")) ^ (to_string (string_repeat (Type [t; cur_d]))) ^ (to_string (Type "}")))) else (Type "}"))];
                    Type [Type "d"; cur_d]
                ]))]);
                for i = (List.length de - 1) downto 0 do
                    let itr = Seq.to_dispenser (List.to_seq (to_list (List.nth de i))) in
                    let dk = next (itr) in
                    let dv = next (itr) in
                    s := append (Type [Type !s; (Type (init_dict [
                        Type [Type "t"; Type "v"];
                        Type [Type "v"; dv];
                        Type [Type "d"; child_d]
                    ]))]);
                    s := append (Type [Type !s; (Type (init_dict [
                        Type [Type "t"; Type "r"];
                        Type [Type "v"; Type ((to_string (Type "\"")) ^ (to_string dk) ^ (to_string (Type "\": ")))];
                        Type [Type "d"; child_d]
                    ]))]);
                    if i > 0 then begin
                        s := append (Type [Type !s; (Type (init_dict [
                            Type [Type "t"; Type "r"];
                            Type [Type "v"; (if to_bool !p then (Type ((to_string (Type ",\n")) ^ (to_string (string_repeat (Type [t; child_d]))))) else (Type ", "))];
                            Type [Type "d"; child_d]
                        ]))]);
                    end;
                done;
                s := append (Type [Type !s; (Type (init_dict [
                    Type [Type "t"; Type "r"];
                    Type [Type "v"; (if to_bool !p then (Type ((to_string (Type "{\n")) ^ (to_string (string_repeat (Type [t; child_d]))))) else (Type "{"))];
                    Type [Type "d"; cur_d]
                ]))]);
                raise Continue
            end;
            r := Type ((to_string !r) ^ (to_string (Type "\"")) ^ (to_string cur_t) ^ (to_string (Type "\"")));
            raise Continue
        with Continue -> ()
    done;
    !r
))
