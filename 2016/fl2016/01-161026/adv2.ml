#use "q4.ml"

let fold_right_by_left f xs e =
  let g h x = fun y -> h (f x y)
  in
  fold_left g (fun x->x) xs e

let fold_left_by_right f e xs =
  let g x h = fun y -> h (f y x)
  in
  fold_right g xs (fun x->x) e

