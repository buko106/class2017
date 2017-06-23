type value = VInt of int | VBool of bool

type expr =
  | EConstInt   of int
  | EAdd        of expr * expr
  | ESub        of expr * expr
  | EMul        of expr * expr
  | EDiv        of expr * expr
  | EConstBool  of bool
  | EIsEqual    of expr * expr
  | ELess       of expr * expr
  | EIfThenElse of expr * expr * expr

exception Eval_error of string

let rec eval e =
  match e with
  | EConstInt x -> VInt x
  | EAdd (x,y)  ->
     begin
       match (eval x,eval y) with
       |(VInt x,VInt y) -> VInt (x+y)
       |(_,_) -> raise (Eval_error "Add")
     end       
  | ESub (x,y)  ->
     begin
       match (eval x,eval y) with
       |(VInt x,VInt y) -> VInt (x-y)
       |(_,_) -> raise (Eval_error "Sub")
     end    
  | EMul (x,y)  ->
     begin
       match (eval x,eval y) with
       |(VInt x,VInt y) -> VInt (x*y)
       |(_,_) -> raise (Eval_error "Mul")
     end    
  | EDiv (x,y)  ->
     begin
       match (eval x,eval y) with
       |(VInt x,VInt y) -> VInt (x/y)
       |(_,_) -> raise (Eval_error "Div")
     end    
  | EConstBool x-> VBool x
  | EIsEqual (x,y)->
     begin
       match (eval x,eval y) with
       | (VBool x,VBool y) -> VBool (x=y)
       | (VInt x,VInt y)   -> VBool (x=y)
       | (_,_)             -> raise (Eval_error "IsEqual")
     end
  | ELess (x,y)->
     begin
       match (eval x,eval y) with
       | (VInt x,VInt y) -> VBool (x<y)
       | (VBool x,VBool y) -> VBool (x<y)
       | (_,_) -> raise (Eval_error "Less")
     end
  | EIfThenElse (i,t,e)->
     begin
       match eval i with
       |VBool true-> eval t
       |VBool false-> eval e
       |_ -> raise (Eval_error "IfThenElse")
     end

(*
if 5 < 10 then
  if true = false then
    10
  else
    5 + 10
else
  5

eval -> 15
 *)
let a =
  EIfThenElse (ELess (EConstInt 5,EConstInt 10)
              ,
                (EIfThenElse 
                   ((EIsEqual (EConstBool true,EConstBool false))
                   ,
                     EConstInt 10
                   ,
                     EAdd (EConstInt 5,EConstInt 10)
                   )
                )
              ,
                EConstInt 5)
(*
if 1+2 then 3 else 4
 *)
let b = EIfThenElse (EAdd (EConstInt 1,EConstInt 2),EConstInt 3,EConstInt 4)
