type order = LT | EQ | GT
                         
module type ORDERED_TYPE =
  sig
    type t
    val compare : t -> t -> order
  end
    
module Assoc =
  functor ( Key : ORDERED_TYPE ) ->
  struct
    type 'a t = (Key.t * 'a) list (*　実体はKeyの値による昇順ordered list *)
    let empty = []
    let rec add assoc key value =
      match assoc with
      | [] -> [(key,value)]
      |(key',value')::assoc' ->
        match Key.compare key key' with
        | LT -> (key,value)::assoc (* Not found -> add *)
        | EQ -> (key,value)::assoc' (* found -> update *)
        | GT -> (key',value'):: add assoc' key value (* continue *)
    let rec remove assoc key =
      match assoc with
      | [] -> ([],None)
      |(key',value')::assoc' ->
        match Key.compare key key' with
        | LT -> (assoc,None)    (* Not found *)
        | EQ -> (assoc',Some value') (* found *)
        | GT -> 
           let (assoc'',result) = remove assoc' key in
           ((key',value')::assoc'',result)
    let rec lookup assoc key =
      match assoc with
      | [] -> None
      |(key',value)::assoc ->
        match Key.compare key key' with
        | LT -> None            (* Not found *)
        | EQ -> Some value      (* found *)
        | GT -> lookup assoc key (* continue *)
    let to_ordered_list assoc = assoc
  end
    
module type ASSOCIATIVE_LIST =
  functor ( Key : ORDERED_TYPE ) ->
  sig
    type 'a t
    val empty : 'a t
    val add : 'a t -> Key.t -> 'a -> 'a t
    val remove : 'a t -> Key.t -> 'a t * 'a option
    val lookup : 'a t -> Key.t -> 'a option
    val to_ordered_list : 'a t -> (Key.t * 'a) list
  end

module Assoc = ( Assoc : ASSOCIATIVE_LIST )

module OrderedString =
struct
  type t = string
  let compare x y = if x < y then LT
                    else if x > y then GT
                    else EQ
end

module StringAssoc = Assoc (OrderedString)
