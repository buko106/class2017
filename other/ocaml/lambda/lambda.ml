let logic_true x y = x
let logic_false x y= y
let logic_and x y = x y logic_false
let logic_or x y = x logic_true y
let logic_not x = x false true


let rec encode n f x =
  if n=0 then
    x
  else f (encode (n-1) f x)

let decode n =
  n (fun x -> x+1) 0

(* val succ : (('a -> 'b) -> 'c -> 'a) -> ('a -> 'b) -> 'c -> 'b = <fun> *)
let succ n f x = f (n f x)


(* val plus : ('a -> 'b -> 'c) -> ('a -> 'd -> 'b) -> 'a -> 'd -> 'c = <fun> *)
let plus m n f x = m f (n f x)


(* val puls :
  (((('a -> 'b) -> 'c -> 'a) -> ('a -> 'b) -> 'c -> 'b) -> 'd -> 'e) ->
  'd -> 'e = <fun>
 *)
let puls m n = m succ n


(* val mult :
  ((('a -> 'b -> 'c) -> 'a -> 'b -> 'd) -> (('e -> 'e) -> 'e -> 'e) -> 'f) ->
  ('a -> 'c -> 'd) -> 'f = <fun>
 *)
let mult m n = m (plus n) (encode 0)


(* val mult : ('a -> 'b) -> ('c -> 'a) -> 'c -> 'b = <fun> *)
let mult m n f = m (n f)


(* error *)
(* let pred n f x = f (fun g h -> h (g f)) (fun u -> x) (fun u -> U) *)


(* val pred :
  ((((('a -> 'a) -> 'a -> 'a) ->
     ((('b -> 'c) -> 'd -> 'b) -> ('b -> 'c) -> 'd -> 'c) ->
     (('a -> 'a) -> 'a -> 'a) -> ('b -> 'c) -> 'd -> 'c) ->
    (('a -> 'a) -> 'a -> 'a) -> ('b -> 'c) -> 'd -> 'c) ->
   ('e -> ('f -> 'f) -> 'f -> 'f) -> (('g -> 'g) -> 'g -> 'g) -> 'h) ->
  'h = <fun> *)
(* let pred n  = n (fun g k -> (g (encode 1)) (fun u -> puls (g k) (encode 1)) k) (fun v -> encode 0) (encode 0) *)
(* # pred (encode 1);;
Error: This expression has type
         (((('a -> 'a) -> 'a -> 'a) ->
           ((('b -> 'c) -> 'd -> 'b) -> ('b -> 'c) -> 'd -> 'c) ->
           (('a -> 'a) -> 'a -> 'a) -> ('b -> 'c) -> 'd -> 'c) ->
          (('a -> 'a) -> 'a -> 'a) ->
          ((('b -> 'c) -> 'd -> 'b) -> ('b -> 'c) -> 'd -> 'c) ->
          (('a -> 'a) -> 'a -> 'a) -> ('b -> 'c) -> 'd -> 'c) ->
         ((('a -> 'a) -> 'a -> 'a) ->
          ((('b -> 'c) -> 'd -> 'b) -> ('b -> 'c) -> 'd -> 'c) ->
          (('a -> 'a) -> 'a -> 'a) -> ('b -> 'c) -> 'd -> 'c) ->
         (('a -> 'a) -> 'a -> 'a) ->
         ((('b -> 'c) -> 'd -> 'b) -> ('b -> 'c) -> 'd -> 'c) ->
         (('a -> 'a) -> 'a -> 'a) -> ('b -> 'c) -> 'd -> 'c
       but an expression was expected of type
         (((('a -> 'a) -> 'a -> 'a) ->
           ((('b -> 'c) -> 'd -> 'b) -> ('b -> 'c) -> 'd -> 'c) ->
           (('a -> 'a) -> 'a -> 'a) -> ('b -> 'c) -> 'd -> 'c) ->
          (('a -> 'a) -> 'a -> 'a) -> ('b -> 'c) -> 'd -> 'c) ->
         ('e -> ('f -> 'f) -> 'f -> 'f) -> (('g -> 'g) -> 'g -> 'g) -> 'h
       The type variable 'b occurs inside ('b -> 'c) -> 'd -> 'b *)



(* val pred :
  ((('a -> 'b) -> ('b -> 'c) -> 'c) -> ('d -> 'e) -> ('f -> 'f) -> 'g) ->
  'a -> 'e -> 'g = <fun> *)
let pred n f x = n (let dammy g h = h (g f) in dammy) (let dammy u = x in dammy) (let dammy u = u in dammy)
