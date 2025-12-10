open Fp_lab_2
module S = Rb_set

let test_empty_is_empty () =
  let s : int S.t = S.empty in
  Alcotest.(check bool) "empty is empty" true (S.is_empty s)
;;

let test_add_mem () =
  let s = S.empty |> S.add 10 |> S.add 5 |> S.add 10 in
  Alcotest.(check bool) "mem 10" true (S.mem 10 s);
  Alcotest.(check bool) "mem 5" true (S.mem 5 s);
  Alcotest.(check bool) "mem 42" false (S.mem 42 s)
;;

let test_of_list_removes_duplicates () =
  let s = S.of_list [ 1; 2; 2; 3; 1 ] in
  let lst = S.to_list s in
  Alcotest.(check (list int)) "to_list" [ 1; 2; 3 ] lst
;;

let test_filter () =
  let s = S.of_list [ 1; 2; 3; 4; 5 ] in
  let s_even = S.filter (fun x -> x mod 2 = 0) s in
  let lst = S.to_list s_even in
  Alcotest.(check (list int)) "only even" [ 2; 4 ] lst
;;

let test_map () =
  let s = S.of_list [ 1; 2; 3 ] in
  let s2 = S.map (fun x -> x * 2) s in
  let lst = S.to_list s2 in
  Alcotest.(check (list int)) "mapped *2" [ 2; 4; 6 ] lst
;;

let test_append_union () =
  let a = S.of_list [ 1; 2; 3 ] in
  let b = S.of_list [ 3; 4; 5 ] in
  let u = S.append a b in
  let lst = S.to_list u in
  Alcotest.(check (list int)) "union" [ 1; 2; 3; 4; 5 ] lst
;;

let test_remove () =
  let s = S.of_list [ 1; 2; 3; 4 ] in
  let s' = S.remove 3 s in
  Alcotest.(check bool) "mem 3 after remove" false (S.mem 3 s');
  Alcotest.(check bool) "mem 2 stays" true (S.mem 2 s')
;;

let unit_tests =
  let open Alcotest in
  [ test_case "empty is empty" `Quick test_empty_is_empty
  ; test_case "add + mem" `Quick test_add_mem
  ; test_case "of_list removes duplicates" `Quick test_of_list_removes_duplicates
  ; test_case "filter" `Quick test_filter
  ; test_case "map" `Quick test_map
  ; test_case "append (union)" `Quick test_append_union
  ; test_case "remove" `Quick test_remove
  ]
;;

(*WRITE PROPERTY TESTS WITH Q_CHECK*)

let () =
  let open Alcotest in
  run "fp-lab-2 - rb-set" [ "unit", unit_tests ]
;;
