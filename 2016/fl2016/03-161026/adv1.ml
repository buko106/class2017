module type EQ =
  sig
    type ('a, 'b) equal
    val refl : ('a,'a) equal
    val symm : ('a,'b) equal -> ('b, 'a) equal
    val trans :
      ('a, 'b) equal -> ('b ,'c) equal -> ('a, 'c) equal
    val apply : ('a, 'b) equal -> 'a -> 'b
  end

module Equal =
  struct
    type ('a, 'b) equal =  PAIR of ('a->'b) * ('b->'a)
    let refl = PAIR ((fun x->x),(fun x->x))
    let symm (PAIR (a2b,b2a)) = PAIR (b2a,a2b)
    let trans (PAIR (a2b,b2a)) (PAIR (b2c,c2b)) =
      PAIR ((fun a -> b2c (a2b a)) ,(fun c -> b2a (c2b c)))
    let apply (PAIR (a2b,_)) = a2b
  end

module Eq : EQ = Equal

type 'a value =
  | VBool of (bool,'a) Eq.equal * bool
  | VInt of (int,'a) Eq.equal * int
type 'a expr =
  |EConstInt of (int, 'a) Eq.equal * int
  |EConstBool of (bool, 'a) Eq.equal * bool
  |EAdd of (int, 'a) Eq.equal * int expr * int expr
  |ESub of (int, 'a) Eq.equal * int expr * int expr
  |EMul of (int, 'a) Eq.equal * int expr * int expr
  |EDiv of (int, 'a) Eq.equal * int expr * int expr
  |EIf of bool expr * 'a expr * 'a expr
  |EEq of (bool, 'a) Eq.equal * int expr * int expr
  |ELess of (bool, 'a) Eq.equal * int expr * int expr

let rec eval : 'a. 'a expr -> 'a value = fun e ->
  match e with
  |EConstInt (t,n) -> VInt (t,n)
  |EConstBool (t,b) -> VBool (t,b)
  |EAdd (t,e1,e2) ->
    begin
      match (eval e2,eval e1) with
      |(VInt(_,n2),VInt(_,n1))-> VInt (t,n1+n2)
      | _ -> VInt (t,0)
    end
  |ESub (t,e1,e2) ->
    begin
      match (eval e2,eval e1) with
      |(VInt(_,n2),VInt(_,n1))-> VInt (t,n1-n2)
      | _ -> VInt (t,0)
    end
  |EMul (t,e1,e2) ->
    begin
      match (eval e2,eval e1) with
      |(VInt(_,n2),VInt(_,n1))-> VInt (t,n1*n2)
      | _ -> VInt (t,0)
    end
  |EDiv (t,e1,e2) ->
    begin
      match (eval e2,eval e1) with
      |(VInt(_,n2),VInt(_,n1))-> VInt (t,n1/n2)
      | _ -> VInt (t,0)
    end
  |EIf (e1,e2,e3) ->
    begin
      match eval e1 with
      |VBool (_,b) -> if b then eval e2 else eval e3
      | _ -> eval e2
    end
  |EEq (t,e1,e2) ->
    begin
      match (eval e2,eval e1) with
      |(VInt(_,n2),VInt(_,n1)) -> VBool (t,n1=n2)
      | _ -> VBool (t,true)
    end
  |ELess (t,e1,e2) ->
    begin
      match (eval e2,eval e1) with
      |(VInt(_,n2),VInt(_,n1)) -> VBool (t,n1<n2)
      | _ -> VBool (t,true)
    end

(*
if 1<(2+3) then
  if 4 = 4 then
    true
  else
    false
else
  false
 *)

let e = EIf ( ELess ( Eq.refl , EConstInt (Eq.refl,1) , EAdd (Eq.refl, EConstInt (Eq.refl,2), EConstInt (Eq.refl,3))),
              EIf ( EEq ( Eq.refl , EConstInt (Eq.refl,4) ,EConstInt (Eq.refl,4)),
                    EConstBool (Eq.refl,true),
                    EConstBool (Eq.refl,false))
              ,
              EConstBool (Eq.refl,false))

let _ = eval e
