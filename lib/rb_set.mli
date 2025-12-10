(** rb_set **)

type 'a t

val empty : 'a t

val is_empty: 'a t ->bool

val mem : 'a -> 'a t -> bool

val add : 'a -> 'a t -> 'a t

val remove : 'a -> 'a t -> 'a t

val of_list : 'a list -> 'a t

val to_list : 'a t -> 'a list

val map : ('a -> 'b) -> 'a t -> 'b t

val filter : ('a -> bool) -> 'a t -> 'a t


val fold_left : ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b

val fold_right : ('a -> 'b -> 'b) -> 'a t -> 'b -> 'b

(**empty monoid **)
val empty_monoid : 'a t

(**appends sets **)
val append : 'a t -> 'a t -> 'a t

(**[subset a b] = true if every value from [a] is contained in [b] **)
val subset : 'a t -> 'a t -> bool

(** compare sets: returns [true] if sets contain same elements **)
val equal : 'a t -> 'a t -> bool


(**pretty-printer for rb-set **)
val pp :
  (Format.formatter -> 'a -> unit) ->
  Format.formatter ->
  'a t ->
  unit