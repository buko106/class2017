let rec fix f x = 
  f (fix f) x

let sum_to n =
  let sum_to_sub f n =
    if n=0 then
      0
    else
      n + f (n-1)
  in fix sum_to_sub n

let is_prime n =
  let is_prime_sub f i =
    if i*i > n then
      true
    else
      if n mod i=0 then
        false
      else
        f (i+1)
  in if n=1 then 
       false
     else
       fix is_prime_sub 2

let gcd x y =
  let gcd_sub f x y =
    if x mod y = 0 then
      y
    else
      f y (x mod y)
  in fix gcd_sub x y
