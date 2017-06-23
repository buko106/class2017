let rec append xs ys =
  match xs with
  |[] -> ys
  |x :: xs -> x :: append xs ys

let rec filter f xs =
  match xs with
  |[]->[]
  |x :: xs when (f x) -> x :: filter f xs
  |x :: xs -> filter f xs
