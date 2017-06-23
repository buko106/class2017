(* alpha conversion *)
let rec x0 x1 =
  let x2 = let x3 = let t0 = -x1 in x1-t0 in
           let t1 = let x4 = -x3 in let t2 = -x4 in x4-t2 in x3-t1 in
  let t4 = -x2 in x2-t4 in
let t5 = 125 in let x5 = x0 t5 in let t6 = -x5 in x5 -t6 ;;

(* A conversion *)

let rec x0 x1 =
  let t0 = -x1 in
  let x3 = x1-t0 in 
  let x4 = -x3  in
  let t2 = -x4 in
  let t1 =  x4-t2 in
  let x2 =  x3-t1 in
  let t4 = -x2 in 
  x2-t4 in
let t5 = 125 in
let x5 = x0 t5 in
let t6 = -x5 in
x5 -t6 ;;
