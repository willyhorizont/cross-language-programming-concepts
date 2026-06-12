let main () =
    let multiply_aa x y = x * y in
    let multiply_bb = fun x y -> x + y in
    let multiply_cc = fun x y ->
        begin
            Printf.printf "Menghitung %d + %d\n" x y;
            let hasil = x + y in
            hasil
        end in
    let multiply_dd = fun x y -> (
        Printf.printf "Menghitung %d + %d\n" x y;
        x + y
        ) in
    ()

let () = main ()
