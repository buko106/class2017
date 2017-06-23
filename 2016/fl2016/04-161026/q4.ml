type 'a m = (int*int) list -> 'a * (int*int) list

(** (>>=) : 'a m -> ('a -> 'b m) -> 'b m *)
let (>>=) (x:'a m) (f : 'a -> 'b m) =
  ((fun table -> let (a,table2) = x table in f a table2):'b m)

(** return : 'a -> 'a m *)
let return x =
  ((fun table -> (x,table)) : 'a m)

(** memo : (int -> int m) -> int -> int m *)
let memo : (int -> int m) -> int -> int m = fun f n ->
  let rec lookup (table:(int*int) list) =
    match table with
    | [] -> None
    |(k,v)::tl -> if k = n then Some v
                  else lookup tl
  in
  fun table -> match lookup table with
               | None -> let (fn,table2) = f n table in
                         (fn,(n,fn)::table2)
               | Some v -> (v,table)
                             
(** runMemo : 'a m -> 'a *)
let runMemo (x : 'a m) = 
  let (v,_) = x [] in v

(** fib : int -> int m **)
let rec fib n = 
  if n <= 1 then
    return n

  else
    (memo fib (n-2)) >>= (fun r1 ->
    (memo fib (n-1)) >>= (fun r2 ->
      return (r1 + r2)))
			   
let _ =
  if runMemo (fib 80) = 23416728348467685 && runMemo (fib 10) = 55 then
    print_string "ok\n"
  else
    print_string "wrong\n"
