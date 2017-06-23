type 'a t =
  | Leaf
  | Node of 'a * (('a t) t)


module rec Tree :sig val map : ('a -> 'b) -> 'a t -> 'b t end =
  struct
    let rec map f at=
      match at with
      |Leaf -> Leaf
      |Node ( a , att) -> Node (f a,Tree.map (Tree.map f) att)
  end

open Tree
