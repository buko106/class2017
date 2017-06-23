(* let rec fix f x = f (fix f) x *)

type 'a t = Tag of ('a t -> 'a)
(* 無理やり型をつける *)

let fix f =
  (fun (Tag x) -> f (fun y -> x (Tag x) y))
    (Tag (fun (Tag x) -> f (fun y -> x (Tag x) y)))

let fact n =
  let fact_sub f n =
    if n < 1 then
      1
    else
      n * f (n-1)
  in
  fix fact_sub n

