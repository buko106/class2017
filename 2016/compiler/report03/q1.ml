(* 書き換え前 *)

let fib_naive n =
  let rec fib_tailrec k fn1 fn =
    if k = n then
      fn
    else
      fib_tailrec (k+1) ((fn1+fn) mod 1000000007) fn1
  in
  fib_tailrec 0 1 0

(* 書き換え後 *)


let fib_naive n =
  let rec fib_tailrec n' k fn1 fn =
    if k = n' then
      fn
    else
      fib_tailrec n' (k+1) ((fn1+fn) mod 1000000007) fn1
  in
  fib_tailrec n 0 1 0
