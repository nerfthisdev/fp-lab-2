open Fp_lab_2

let () =
  let module S = Rb_set in
  let s = S.empty |> S.add 3 |> S.add 1 |> S.add 2 |> S.add 2 in
  Format.printf "Set s = ";
  S.pp Format.pp_print_int Format.std_formatter s;
  Format.printf "@."
;;
