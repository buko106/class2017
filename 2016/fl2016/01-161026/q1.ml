let rec sum_to n =
  if n=0 then
    0
  else
    n + sum_to (n-1)

let is_prime n =
  let rec is_prime_rec n i =
    if i*i > n then
      true
    else
      if n mod i=0 then
        false
      else
        is_prime_rec n (i+1)
  in if n=1 then
       false
     else 
       is_prime_rec n 2

let rec gcd x y =
  if x mod y = 0 then
    y
  else
    gcd y (x mod y)
