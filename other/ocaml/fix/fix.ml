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


(* # #use "adv1.ml";; *)
(* type 'a t = Tag of ('a t -> 'a) *)
(* val fix : (('a -> 'b) -> 'a -> 'b) -> 'a -> 'b = <fun> *)
(* val fact : int -> int = <fun> *)
(* # fact 0;; *)
(* - : int = 1 *)
(* # fact 1;; *)
(* - : int = 1 *)
(* # fact 2;; *)
(* - : int = 2 *)
(* # fact 3;; *)
(* - : int = 6 *)
(* # fact 10;; *)
(* - : int = 3628800 *)
(* # fact 20;; *)
(* - : int = 2432902008176640000 *)
(* Z = λf. (λx. f (λy. x x y)) (λx. f (λy. x x y)) というZコンビネータ（値渡しでも使える不動点コンビネータ）に、型が合わないので再帰ヴァリアントで無理やり型をつけたら動きました。*)
