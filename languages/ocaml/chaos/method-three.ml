type any = Any : 'a -> any

let rec print_any (Any x) : unit =
  let obj = Obj.magic x in
  (* Cek apakah datanya adalah Blok Memori (String, List, Float) atau Nilai Langsung (Int, Bool) *)
  if Obj.is_block obj then begin
    let tag = Obj.tag obj in
    if tag = Obj.string_tag then
      print_string ("\"" ^ (Obj.magic x : string) ^ "\"")
    else if tag = Obj.double_tag then
      print_string (string_of_float (Obj.magic x : float))
    else
      (* Mengasumsikan blok memori lainnya adalah List *)
      let l : any list = Obj.magic x in
      print_string "[";
      List.iter (fun elem -> print_any elem; print_string "; ") l;
      print_string "]"
  end else begin
    (* Nilai Integer dan Boolean di OCaml disimpan sebagai Unboxed Integer *)
    let i : int = Obj.magic x in
    if i = 0 then print_string "false (atau angka 0)"
    else if i = 1 then print_string "true (atau angka 1)"
    else print_string (string_of_int i)
  end

let () =
    let some_python_like_list : any list = [
        Any true;
        Any "foo";
        Any 123;
        Any 123.45;
        Any [Any 1; Any 2];
    ] in
    List.iter (fun x -> print_any x; print_newline ()) some_python_like_list
