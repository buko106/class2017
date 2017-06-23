type order = LT | EQ | GT

module type ORDERED_TYPE = 
sig 
  type t
  val compare : t -> t -> order 
end

module type MULTISET2 = 
  functor (T : ORDERED_TYPE) -> 
    sig 
      type t 
      val empty : t 
      val add    : T.t -> t -> t 
      val remove : T.t -> t -> t 
      val count  : T.t -> t -> int 
    end 

module Multiset2 : MULTISET2 =
  functor (T : ORDERED_TYPE) -> struct 
    type 'a tree = Leaf | Node of 'a * 'a tree * 'a tree
    type t = T.t tree
    let empty = Leaf
    let rec add value t = 
      match t with
      |Leaf -> Node (value,Leaf,Leaf)
      |Node (v,left,right) -> 
        match T.compare value v with
        |LT -> Node (v,add value left,          right)
        | _ -> Node (v,          left,add value right)
    let rec remove_min t =
      match t with
      |Leaf -> failwith "Can't remove_min"
      |Node (v,left,right) ->
        match left with
        |Leaf -> (v, right)
        | _ -> 
           let (min,left') = remove_min left in
           (min,Node (v,left',right))
    let remove_root t =
      match t with
      |Leaf -> failwith "Can't remove_root"
      |Node (v,left,right) ->
        match (left,right) with
        |(Leaf,_) -> right
        |(_,Leaf) -> left
        |(_,_) -> 
          let (v',right') = remove_min right in
          Node (v',left,right')
    let rec remove value t =
      match t with
      |Leaf -> Leaf
      |Node (v,left,right) ->
        match T.compare value v with
        |LT -> Node (v,remove value left,             right)
        |GT -> Node (v,             left,remove value right)
        |EQ -> remove_root t
    let rec count value t =
      match t with
      |Leaf -> 0
      |Node (v,left,right)->
        match T.compare value v with
        |LT -> count value left
        |GT -> count value right
        |EQ -> count value left + count value right + 1 (* find *)
  end

module OrderedString =
struct
  type t = string
  let compare x y = 
    let r = Pervasives.compare x y in
      if      r > 0 then GT 
      else if r < 0 then LT 
      else               EQ
end 

module StringMultiset =
  Multiset2 (OrderedString)
