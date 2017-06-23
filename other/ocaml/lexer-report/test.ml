let int_of_fun f =
  f (fun x->x+1) 0

let zero f =
  fun f x -> x

let one f =
  fun f x -> f x

let rec fun_of_int n =
  if n=0 then
    fun f x -> x
  else
    fun f x-> fun_of_int (n-1) f (f x)

let add g h =
  fun f x -> (g f) ((h f) x)

let mul g h =
  fun f x -> (g (h f)) x

let pred g =
  g (fun g k -> (g one) (fun u-> add (g k) one) k) (fun u->zero) zero

let sub g h =
  fun f x-> (h (pred f)) ((g f) x)
