(* common subexpression elimination for KNormal.t *)
open KNormal


let rec effect = function (* copy from elim.ml*)
  | Let(_, e1, e2) | IfEq(_, _, e1, e2) | IfLE(_, _, e1, e2) -> effect e1 || effect e2
  | LetRec(_, e) | LetTuple(_, _, e) -> effect e
  | App _ | Put _ | ExtFunApp _ -> true
  | _ -> false



(* A Knormal.t expression has no side effect if t has no function call and Put to an array *)
let rec f = function 
  | IfEq(x,y, e1, e2) -> IfEq(x,y, f e1, f e2)
  | IfLE(x,y, e1, e2) -> IfLE(x,y, f e1, f e2)
  | Let((x,t),e1,e2) ->         (* top-down *)
     let e1' = f e1 in
     if effect e1' then
       Let((x, t), e1', f e2)
     else
       let e2' = g x e1' e2 in
       Let((x, t), e1', f e2')
  | LetRec({ name = (x,ty); args = yts; body = s} , t) ->
     LetRec({ name = (x,ty); args = yts; body = f s} , f t)
  | LetTuple(yts,x,t) -> LetTuple(yts,x,f t)
  | e -> e

and equal e1 e2 =
  match (e1,e2) with
  | (Unit,Unit) | (Int _,Int _) | (Float _,Float _)
    -> false (* always false for immediate*)
  | (e1,e2) when e1 = e2 -> true
  | (Add(a1,b1),Add(a2,b2)) | (FAdd(a1,b1),FAdd(a2,b2)) |(FMul(a1,b1),FMul(a2,b2)) | (Add(a1,b1),Add(a2,b2)) (* commutative 2-ary op *)
    -> a1 = b2 && b1 = a2
  | _ -> false

and g v e1 e2 = (* if you call g, confirm e1 has no side effect*)
  (* x = e1(no effect), replacing e1 with Var(x) *)
  (* e1 has no size effect , therefore a + b is equal to b + a and so on. *)
  match e2 with
  | e2 when equal e1 e2 -> 
     (Format.eprintf "replace subexpression with %s@." v;Var v)
  | IfEq (x,y,s,t) -> IfEq(x,y,g v e1 s,g v e1 t)
  | IfLE (x,y,s,t) -> IfLE(x,y,g v e1 s,g v e1 t)
  | Let((x,ty),s,t) ->
     let s' = g v e1 s in
     if effect s' then
       Let((x,ty),s',t)
     else
       Let((x,ty),s',g v e1 t)
  | LetRec({ name = (x,ty); args = yts; body = s} , t) ->
     let s' = g v e1 s in
     if effect s' then
       LetRec({ name = (x,ty); args = yts; body = s'} , t)
     else
       LetRec({ name = (x,ty); args = yts; body = s'} 
                , g v e1 t)
  | LetTuple(yts,x,t) -> LetTuple(yts,x,g v e1 t)
  | e2 -> e2
