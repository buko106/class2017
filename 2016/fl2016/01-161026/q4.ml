let fold_right f xs e =
  let reverse xs =
    let rec reverse_tailrec xs ret =
      match xs with
        [] -> ret
      |x::xs-> reverse_tailrec xs (x::ret)
    in
    reverse_tailrec xs []
  in
  let rec fold_right_tailrec xs ret =
    match xs with
      [] -> ret
    |x:: xs -> fold_right_tailrec xs (f x ret)
  in
  fold_right_tailrec (reverse xs) e
        
let fold_left f e xs =
  let rec fold_left_tailrec xs ret =
    match xs with
    |[] -> ret
    |x :: xs -> fold_left_tailrec xs (f ret x)
  in fold_left_tailrec xs e
