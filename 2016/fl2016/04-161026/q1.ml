type 'a m = Ok of 'a | Err of string

(** (>>=) : 'a m -> ('a -> 'b m) -> 'b m *)
let (>>=) x f =
  match x with
  | Ok(v) -> f v
  | Err msg -> Err msg

(** return : 'a -> 'a m *)
let return x = Ok x

(** err : string -> 'a m *)
let err msg = Err msg
		  
				
(** myDiv : int -> int -> int m *)
let myDiv x y =
  if y = 0 then
    Err "Division by Zero"
  else
    return (x / y)

(** eLookup : 'a -> ('a * 'b) list -> 'b m *)
let rec eLookup key t =
  match t with
  | [] -> Err "Not found"
  |(k,v)::tl -> 
    if k = key then
      Ok v
    else
      eLookup key tl

(** lookupDiv : 'a -> 'a -> ('a * int) list -> int m *)
let lookupDiv kx ky t =
  eLookup kx t >>= (fun x ->
  eLookup ky t >>= (fun y ->
  myDiv x y))

(** Tests *)
let table = [("x", 6); ("y", 0); ("z", 2) ]

let isErr x =
  match x with
  | Ok(_) -> false
  | Err(_) -> true

let _ =
  let b1 = isErr (lookupDiv "x" "y" table) in
  let b2 = (Ok 3 = lookupDiv "x" "z" table) in
  let b3 = isErr (lookupDiv "x" "a" table) in
  let b4 = isErr (lookupDiv "a" "z" table) in
  if b1 && b2 && b3 && b4 then
    print_string "ok\n"
  else
    print_string "wrong\n"
