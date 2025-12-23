open Fp_lab_2
module S = Rb_set

(*unit tests*)
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

let test_intersection () =
  let a = S.of_list [ 1; 2; 3; 4 ] in
  let b = S.of_list [ 3; 4; 5 ] in
  let i = S.intersection a b in
  let lst = S.to_list i in
  Alcotest.(check (list int)) "intersection" [ 3; 4 ] lst
;;

let test_difference () =
  let a = S.of_list [ 1; 2; 3; 4 ] in
  let b = S.of_list [ 3; 4; 5 ] in
  let d = S.difference a b in
  let lst = S.to_list d in
  Alcotest.(check (list int)) "difference" [ 1; 2 ] lst
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
  ; test_case "intersection" `Quick test_intersection
  ; test_case "difference" `Quick test_difference
  ]
;;

(*prop tests*)

(* prop tests *)
let qcheck_tests =
  let open QCheck in
  let gen_small_nat = (Gen.small_nat [@alert "-deprecated"]) in
  (* Генератор случайных множеств int:
     берём список ints -> превращаем в set *)
  let gen_int_set : int S.t arbitrary =
    make
      ~print:(fun s ->
        (* удобно, чтобы QCheck печатал контрпример *)
        let xs = S.to_list s in
        "[" ^ String.concat "; " (List.map string_of_int xs) ^ "]")
      Gen.(map S.of_list (list gen_small_nat))
  in
  (* Набор предикатов, чтобы тестировать filter без fun1 *)
  let gen_pred : (int -> bool) Gen.t =
    (Gen.oneofl
       [ (fun x -> x mod 2 = 0)
       ; (* even *)
         (fun x -> x mod 2 <> 0)
       ; (* odd *)
         (fun x -> x >= 0)
       ; (* non-negative *)
         (fun x -> x < 10)
       ; (* < 10 *)
         (fun x -> x <> 0) (* not zero *)
       ]
     [@alert "-deprecated"])
  in
  let arb_pred : (int -> bool) arbitrary = make ~print:(fun _ -> "<pred>") gen_pred in
  let monoid_assoc =
    Test.make
      ~name:"append is associative"
      (triple gen_int_set gen_int_set gen_int_set)
      (fun (a, b, c) ->
         let left = S.append a (S.append b c) in
         let right = S.append (S.append a b) c in
         S.equal left right)
  in
  let monoid_left_id =
    Test.make ~name:"empty is left identity" gen_int_set (fun a ->
      let res = S.append S.empty_monoid a in
      S.equal res a)
  in
  let monoid_right_id =
    Test.make ~name:"empty is right identity" gen_int_set (fun a ->
      let res = S.append a S.empty_monoid in
      S.equal res a)
  in
  let prop_add_mem =
    let arb = pair (small_nat [@alert "-deprecated"]) gen_int_set in
    Test.make ~name:"mem x (add x s)" arb (fun (x, s) ->
      let s' = S.add x s in
      S.mem x s')
  in
  let prop_remove_not_mem =
    let arb = pair (small_nat [@alert "-deprecated"]) gen_int_set in
    Test.make ~name:"not (mem x (remove x s))" arb (fun (x, s) ->
      let s' = S.remove x s in
      not (S.mem x s'))
  in
  let prop_filter_all_sat =
    Test.make
      ~name:"all elements of filter p s satisfy p"
      (pair arb_pred gen_int_set)
      (fun (p, s) ->
         let s' = S.filter p s in
         S.fold_left (fun ok x -> ok && p x) true s')
  in
  [ monoid_assoc
  ; monoid_left_id
  ; monoid_right_id
  ; prop_add_mem
  ; prop_remove_not_mem
  ; prop_filter_all_sat
  ]
;;

(* ---------- Запуск, как в первой лабе ---------- *)

let () =
  let open Alcotest in
  run
    "fp-lab-2 – rb-set"
    [ "unit", unit_tests
    ; "properties", List.map QCheck_alcotest.to_alcotest qcheck_tests
    ]
;;
