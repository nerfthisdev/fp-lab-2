open Fp_lab_2

let time label f =
  let start = Unix.gettimeofday () in
  let res = f () in
  let stop = Unix.gettimeofday () in
  Format.printf "%s: %.6fs@." label (stop -. start);
  res
;;

let make_data n =
  let max_v = (n * 3) + 1 in
  List.init n (fun _ -> Random.int max_v)
;;

let bench_add n =
  let data = make_data n in
  ignore (time (Format.sprintf "add (%d)" n) (fun () ->
    List.fold_left (fun s x -> Rb_set.add x s) Rb_set.empty data))
;;

let bench_mem n =
  let data = make_data n in
  let s = List.fold_left (fun acc x -> Rb_set.add x acc) Rb_set.empty data in
  ignore (time (Format.sprintf "mem (%d)" n) (fun () ->
    List.iter (fun x -> ignore (Rb_set.mem x s)) data))
;;

let bench_remove n =
  let data = make_data n in
  let s = List.fold_left (fun acc x -> Rb_set.add x acc) Rb_set.empty data in
  ignore (time (Format.sprintf "remove (%d)" n) (fun () ->
    List.fold_left (fun acc x -> Rb_set.remove x acc) s data))
;;

let () =
  Random.self_init ();
  let n = ref 50_000 in
  let speclist =
    [ "-n", Arg.Set_int n, "Number of elements (default 50000)" ]
  in
  let usage = "fp-lab-2-bench [-n N]" in
  Arg.parse speclist (fun _ -> ()) usage;
  bench_add !n;
  bench_mem !n;
  bench_remove !n
;;
