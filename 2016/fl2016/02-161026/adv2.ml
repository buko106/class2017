type false_t = { t : 'a. 'a }
type 'a not_t = 'a -> false_t
type ('a, 'b) and_t = 'a * 'b
type ('a, 'b) or_t = L of 'a | R of 'b

let one f g =
  (fun x -> g (f x))

let two : ('a, ('b , 'c) and_t) or_t -> (('a, 'b) or_t , ('a, 'c) or_t) and_t =
  fun x ->
  match x with
  |L a-> (L a,L a)
  |R (b,c)-> (R b,R c)

let three :(('a, 'b) or_t ,('a, 'c) or_t) and_t -> ('a,('b,'c)and_t) or_t =
  fun (l,r) ->
  match l with
  |L a -> L a
  |R b->
    begin
      match r with
      |L a -> L a
      |R c -> R (b,c)
    end

let rec callcc
        :(('a -> false_t) -> 'a)->'a
  = fun f -> callcc f

let four :('a->'c)->('a not_t->'c)->'c=
  fun f g ->
  callcc (fun nc -> g (fun a ->nc (f a)))

let six : (('a->'b)->'a)->'a =
  fun f ->
  callcc (fun na -> f (fun a -> (na a).t))



(* let left : 'a -> ('a , 'a not_t) or_t *)
(*   = fun a -> L a *)
(* let right : ('a not_t) -> ('a ,'a not_t) or_t *)
(*   = fun na -> R na *)
(* let four : ('a , 'a not_t) or_t = *)
(*   callcc (fun (k:('a,'a not_t)or_t->false_t) -> right (fun (x:'a) -> k (left x))) 
型推論器が止まらない*)
