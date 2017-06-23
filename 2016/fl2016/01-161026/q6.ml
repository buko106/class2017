#use "q4.ml"

let append_by_left xs ys = 
  fold_left (fun f x-> fun xs-> f (x::xs) ) (fun x->x) xs ys

let filter_by_left f xs =
  fold_left (fun g x-> fun xs-> if f x then g (x::xs) else g xs) (fun x->x) xs []

let append_by_right xs ys = 
  fold_right (fun x xs -> x::xs) xs ys
                    
let filter_by_right f xs =
  fold_right (fun x xs -> if f x then x::xs else xs) xs []
