#use "q4.ml"

let reverse xs =
  let rec reverse_tailrec xs ret =
    match xs with
      [] -> ret
    |x::xs -> reverse_tailrec xs (x::ret)
  in
  reverse_tailrec xs []

let reverse_naive xs =
  fold_right (fun x xs -> xs@[x]) xs []

let reverse_by_fold_right xs =
  let f x g = fun xs -> g (x::xs)
  in
  fold_right f xs (fun x->x) []

let rec make_reversed n =
  if n=1 then 
    [1] 
  else 
    n :: make_reversed (n-1)

let a = make_reversed 5000

