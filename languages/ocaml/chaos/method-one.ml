(* Pendekatan ini mewajibkan kita mendefinisikan batas tipenya *)
type any = [
  | `Any of unit
  | `Any of bool
  | `Any of string
  | `Any of int
  | `Any of float
  | `Any of any list
]

let rec print_any (x : any) : unit =
  match x with
  | `Any () -> print_string "None"
  | `Any (b : bool) -> print_string (string_of_bool b)
  | `Any (s : string) -> print_string ("\"" ^ s ^ "\"")
  | `Any (i : int) -> print_string (string_of_int i)
  | `Any (f : float) -> print_string (string_of_float f)
  | `Any (l : any list) ->
      print_string "[";
      List.iter (fun elem -> print_any elem; print_string "; ") l;
      print_string "]"

let () =
    let some_python_like_list = [
        `Any ();
        `Any true;
        `Any "foo";
        `Any 123;
        `Any [`Any 1; `Any 2];
    ] in
    (* Mencetak seluruh isi list *)
    List.iter (fun x -> print_any x; print_newline ()) some_python_like_list
