let rec fold_right f xs (e:'b) =
  match xs with
  | []  -> e
  |x::xs-> f x (fold_right f xs e)

let fold_left f (e:'b) xs =
  let rec fold_left_tailrec f ret xs =
    match xs with
    | []  -> ret
    |x::xs-> fold_left_tailrec f (f ret x) xs
  in
  fold_left_tailrec f e xs

let reverse xs =
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

let a = make_reversed 10000

let fold_right_by_left f xs e =
  let g h x = fun y -> h (f x y)
  in
  fold_left g (fun x->x) xs e

let fold_left_by_right f e xs =
  let g x h = fun y -> h (f y x)
  in
  fold_right g xs (fun x->x) e

