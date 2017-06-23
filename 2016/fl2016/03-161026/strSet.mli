
(* the interface of sets of ordered strings *)

type t
val empty           : t
val add             : string -> t -> t
val remove          : string -> t -> t
val count           : string -> t -> int
val to_ordered_list : t -> string list
