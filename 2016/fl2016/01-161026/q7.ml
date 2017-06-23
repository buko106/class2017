let rec map f xs =
  match xs with
  |[] -> []
  | x :: xs -> f x :: map f xs

let rec perm xs =
  let rec perm_sub xs ys ret =
    match ys with
    |[]->ret
    |y::ys->perm_sub (y::xs) ys (ret@map (fun zs->y::zs) (perm (xs@ys)))
  in
  match xs with
  |[]->[[]]
  |_-> perm_sub [] xs []
