type color =
  | R
  | B

type 'a tree =
  | Empty
  | Node of color * 'a tree * 'a * 'a tree

type 'a t = 'a tree

let empty = Empty
let empty_monoid = Empty

let is_empty = function
  | Empty -> true
  | _ -> false
;;

let rec mem x = function
  | Empty -> false
  | Node (_, l, v, r) ->
    let c = Stdlib.compare x v in
    if c = 0 then true else if c < 0 then mem x l else mem x r
;;

let balance = function
  (* TODO: make full balancing*)
  | color, a, x, b -> Node (color, a, x, b)
;;

let add x t =
  let rec ins = function
    | Empty -> Node (R, Empty, x, Empty)
    | Node (color, l, v, r) as node ->
      let c = Stdlib.compare x v in
      if c = 0
      then node
      else if c < 0
      then balance (color, ins l, v, r)
      else balance (color, l, v, ins r)
  in
  match ins t with
  | Empty -> assert false
  | Node (_, l, v, r) -> Node (B, l, v, r)
;;

(*реализовать*)
let remove _x t = t

let rec to_list = function
  | Empty -> []
  | Node (_, l, v, r) -> to_list l @ (v :: to_list r)
;;

let of_list lst = List.fold_left (fun acc x -> add x acc) empty lst

let rec fold_left f acc = function
  | Empty -> acc
  | Node (_, l, v, r) ->
    let acc1 = fold_left f acc l in
    let acc2 = f acc1 v in
    fold_left f acc2 r
;;

let rec fold_right f t acc =
  match t with
  | Empty -> acc
  | Node (_, l, v, r) ->
    let acc1 = fold_right f r acc in
    let acc2 = f v acc1 in
    fold_right f l acc2
;;

let map f t = to_list t |> List.map f |> of_list
let filter p t = fold_left (fun acc x -> if p x then add x acc else acc) empty t
let append a b = fold_left (fun acc x -> add x acc) a b
let subset a b = fold_left (fun ok x -> ok && mem x b) true a
let equal a b = subset a b && subset b a

let pp pp_elt fmt t =
  Format.fprintf fmt "{ ";
  let first = ref true in
  fold_left
    (fun () x ->
       if not !first then Format.fprintf fmt ", ";
       first := false;
       pp_elt fmt x)
    ()
    t;
  Format.fprintf fmt " }"
;;
