open Fp_lab_2

let make_data n =
  let max_v = (n * 3) + 1 in
  List.init n (fun _ -> Random.int max_v)
;;

let build_set data =
  List.fold_left (fun acc x -> Rb_set.add x acc) Rb_set.empty data
;;

let run ~n ~seconds ~repeat =
  let data = make_data n in
  let s = build_set data in
  let benches : (string * (unit -> unit) * unit) list =
    [ (Format.sprintf "add (%d)" n, (fun () -> ignore (build_set data)), ())
    ; ( Format.sprintf "mem (%d)" n
      , (fun () -> List.iter (fun x -> ignore (Rb_set.mem x s)) data)
      , () )
    ; ( Format.sprintf "remove (%d)" n
      , (fun () ->
          ignore (List.fold_left (fun acc x -> Rb_set.remove x acc) s data))
      , () )
    ]
  in
  let results = Benchmark.throughputN ~repeat seconds benches in
  Benchmark.tabulate results;
  Benchmark.print_gc results
;;

let () =
  Random.self_init ();
  let n = ref 1_000 in
  let seconds = ref 1 in
  let repeat = ref 3 in
  let speclist =
    [ "-n", Arg.Set_int n, "Number of elements (default 1000)"
    ; "-seconds", Arg.Set_int seconds, "Seconds per test (default 1)"
    ; "-repeat", Arg.Set_int repeat, "Repeats per test (default 3)"
    ]
  in
  let usage = "fp-lab-2-bench [-n N] [-seconds S] [-repeat R]" in
  Arg.parse speclist (fun _ -> ()) usage;
  run ~n:!n ~seconds:!seconds ~repeat:!repeat
;;
