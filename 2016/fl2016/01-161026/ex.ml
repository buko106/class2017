let circle r =
  r *. r *. acos (-1.)
                 
let rec sigma f n =
  if n=0 then
    f n
  else
    f n + sigma f (n-1)
                
let rec map f l =
  match l with
  |[] -> []
  | x :: l -> f x :: map f l
