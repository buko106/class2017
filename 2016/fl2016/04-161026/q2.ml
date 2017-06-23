(* Definition of "the" list monad *)
type 'a m = 'a list

(** (>>=) : 'a m -> ('a -> 'b m) -> 'b m *)
let (>>=) (x : 'a m) (f : 'a -> 'b m) =
  List.concat (List.map f x)

(** return : 'a -> 'a m *)
let return (x : 'a) = [x]

(** guard : bool -> unit m *)
let guard (x : bool) =
  if x then return () else []

(** check if "banana + banana = sinamon" *)
let test_banana ba na si mo n =
  (100 * ba + 10 * na + na
   + 100 * ba + 10 * na + na
   = 1000 * si + 100 * na + 10 * mo + n)

(** check if "send + more = money" *)
let test_money s e n d m o r y =
  (1000 * s + 100 * e + 10 * n + d
   + 1000 * m + 100 * o + 10 * r + e
   = 10000 * m + 1000 * o + 100 * n + 10 * e + y)


let solve =
  [0;1;2;3;4;5;6;7;8;9] >>= (fun ba ->
  [0;1;2;3;4;5;6;7;8;9] >>= (fun na ->
  [0;1;2;3;4;5;6;7;8;9] >>= (fun si ->
  [0;1;2;3;4;5;6;7;8;9] >>= (fun mo ->
  [0;1;2;3;4;5;6;7;8;9] >>= (fun nn ->
  (guard (200*ba + 22*na = 1000*si + 100*na + 10*mo + nn)) >>= (fun _ ->
  return (ba,na,na,si,na,mo,nn)))))))

let solve2 =
  [0;1;2;3;4;5;6;7;8;9] >>= (fun d ->
  [0;1;2;3;4;5;6;7;8;9] >>= (fun e ->
  (guard ( e <> d ))    >>= (fun _ ->
  [0;1;2;3;4;5;6;7;8;9] >>= (fun y ->
  (guard ( y <> e && y <> d ))
                        >>= (fun _ -> 
  (guard ((d+e) mod 10 = y))
                        >>= (fun _ ->
  [0;1;2;3;4;5;6;7;8;9] >>= (fun n ->
  (guard ( n <> y && n <> e && n <> d))
                        >>= (fun _ ->
  [0;1;2;3;4;5;6;7;8;9] >>= (fun r ->
  (guard ( r <> n && r <> y && r <> e && r <> d ))
                        >>= (fun _ ->
  (guard ((10*n + d + 10*r + e) mod 100 = 10*e + y))
                        >>= (fun _ ->
  [0;1;2;3;4;5;6;7;8;9] >>= (fun o ->
  (guard ( o <> r && o <> n && o <> y && o <> e && o <> d))
                        >>= (fun _ ->
  (guard ((100*e + 10*n + d + 100*o + 10*r + e) mod 1000= 100*n + 10*e + y))
                        >>= (fun _ ->
  [1;2;3;4;5;6;7;8;9]   >>= (fun s ->
  (guard ( s <> o && s <> r && s <> n && s <> y && s <> e && s <> d)) 
                        >>= (fun _ ->
  [1;2;3;4;5;6;7;8;9]   >>= (fun m ->
  (guard( m <> s && m <> o && m <> r && m <> n && m <> y && m <> e && m <> d))
                        >>= (fun _ ->
  (guard ( 1000*s + 100*e + 10*n + d + 1000*m + 100*o + 10*r + e
               = 10000*m + 1000*o + 100*n + 10*e + y))
                        >>= (fun _ ->
  return (s,e,n,d,m,o,r,e,m,o,n,e,y))))))))))))))))))))

let check_banana = 
  List.map (fun (ba,na,_,si,_,mo,nn) ->  test_banana ba na si mo nn) solve
let check_money =
  List.map (fun (s,e,n,d,m,o,r,_,_,_,_,_,y) -> test_money s e n d m o r y) solve2
(* SEND + MORE = MONEY
   9567 + 1085 = 10652 *)
