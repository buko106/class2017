open Absyn2

(* values of expressions and functions *)
type value = 
   UNIT
 | INT of int 
 | STRING of string
 | Fun of string list * exp * env ref (* function *)
     (* the last element keeps the function's own environment,
        used when the function is called
      *)
 | Prim of string (* primitive functions *)

 (* environment, which maps a variable/function name to 
    *a reference to* its value.
    The reference cell is needed to support imperative updates.
 *)
and env = (string * value ref) list

(* initial environment, which holds values of primitive functions *)
let init_env = [("print", ref (Prim "print"));
                 ("flush", ref (Prim "flush"));
                 ("getchar", ref (Prim "getchar"));
                 ("ord",ref (Prim "ord"));
                 ("chr", ref (Prim "chr"));
                 ("size", ref (Prim "size"));
                 ("substring", ref (Prim "substring"));
                 ("concat", ref (Prim "concat"));
                 ("not", ref (Prim "not"));
                 ("exit", ref (Prim "exit"))]

(* evaluation function for primitive functions *)
let eval_prim pr vs =
  match pr with
   "print" -> 
      (match vs with [STRING(s)] -> (print_string s; UNIT)
                    | _-> assert false)
 | "flush" -> (flush stdout; UNIT)
 | "getchar" ->
    ( try
      let c = input_char stdin in
         STRING(String.make 1 c)
     with End_of_file -> STRING("")
    )
 | "ord" ->
      (match vs with [STRING(s)] -> INT(int_of_char(s.[0]))
              | _ -> assert false)
 | "chr" ->
      (match vs with [INT(n)] -> STRING(String.make 1 (char_of_int(n)))
              | _ -> assert false)
 | "size" ->
      (match vs with [STRING(s)] -> INT(String.length s)
             | _ -> assert false)
 | "substring" ->
      (match vs with 
        [STRING(s);INT(first);INT(n)] -> STRING(String.sub s first n)
       | _ -> assert false)
 | "concat" ->
      (match vs with [STRING(s1);STRING(s2)] -> STRING(s1^s2)
         | _ -> assert false)
 | "not" ->
      (match vs with [INT(n)] -> if n=0 then INT(1) else INT(0)
         | _ -> assert false)
 | "exit" ->
      (match vs with [INT(n)] ->
          (print_string ("exit with state "^(string_of_int n)^"\n");
           exit 0)
        | _ -> assert false)
 | _ -> assert false

(* left-value, used in assignment expressions *)
type lval = LvalSimpl of value ref

(* lookup the value of a variable/function *)
let lookup_venv v venv = 
  try List.assoc v venv 
  with Not_found -> (print_string ("Undefined symbol: "^v^"\n");
                    assert false)

(* extend the environment venv *)
let extend_venv venv vars vals =
  let new_venv = List.combine vars (List.map (fun v-> ref v) vals) in
    new_venv@venv

(* a function on lists, that returns the last element *)
let rec list_last l =
  match l with
    [] -> assert false
  | [x] -> x
  | x::l' -> list_last l'

(* evaluation functions for primitive operations *)
let plusOp x y =
  match (x,y) with
      (INT(n1), INT(n2)) -> INT(n1+n2)
    | _ -> assert false
let minusOp x y =
  match (x,y) with
      (INT(n1), INT(n2)) -> INT(n1-n2)
    | _ -> assert false
let timesOp x y =
  match (x,y) with
      (INT(n1), INT(n2)) -> INT(n1*n2)
    | _ -> assert false
let divideOp x y =
  match (x,y) with
      (INT(n1), INT(n2)) -> INT(n1/n2)
    | _ -> assert false
let bool2exp b =
  if b then INT(1) else INT(0)
let eqOp v1 v2 = 
  match (v1,v2) with
    (INT(n1),INT(n2)) -> bool2exp(n1=n2)
  | (STRING(s1),STRING(s2)) -> bool2exp(s1=s2 )
  | _ -> assert false
let neqOp v1 v2 = 
  match (v1,v2) with
    (INT(n1),INT(n2)) -> bool2exp(n1!=n2)
  | (STRING(s1),STRING(s2)) -> bool2exp(s1!=s2)
  | _ -> assert false
let ltOp v1 v2 = 
  match (v1,v2) with
    (INT(n1),INT(n2)) -> bool2exp(n1<n2)
  | (STRING(s1),STRING(s2)) -> bool2exp(s1<s2)
  | _ -> assert false
let leOp v1 v2 = 
  match (v1,v2) with
    (INT(n1),INT(n2)) -> bool2exp(n1<=n2)
  | (STRING(s1),STRING(s2)) -> bool2exp(s1<=s2)
  | _ -> assert false

let lookup_op (oper,ty) =
  match oper with
    Absyn.PlusOp -> plusOp
  | Absyn.MinusOp -> minusOp
  | Absyn.TimesOp -> timesOp
  | Absyn.DivideOp -> divideOp
  | Absyn.EqOp -> eqOp
  | Absyn.NeqOp -> neqOp
  | Absyn.LtOp -> ltOp
  | Absyn.LeOp -> leOp


(* main evaluation function *)
let rec eval_exp exp env =
  match exp with
    VarExp(v) -> eval_var v env
  | NilExp -> UNIT
  | IntExp(n) -> INT(n)
  | StringExp(s) -> STRING(s)
  | CallExp(f, args) ->
     let vs = eval_exps args env in
     (match !(lookup_venv f env) with
        Fun(formals, e1, env1) ->
         let env' = extend_venv !env1 formals vs in
            eval_exp e1 env'
       | Prim s -> eval_prim s vs
       | _ -> assert false
     )
  | OpExp(e1, oper, e2) ->
      let v1 = eval_exp e1 env in
      let v2 = eval_exp e2 env in
      let f = lookup_op oper in
         f v1 v2
  | SeqExp(exps) ->
      let vs = eval_exps exps env in
        list_last vs
  | AssignExp(var,e) ->
      let lval = lval_of_var var env in
      let v = eval_exp e env in
        (eval_assign lval v; UNIT)
  | IfExp(cond, e_then, e_else) ->
      let v0 = eval_exp cond env in
       ( match v0 with
          INT(n) ->
            if n!=0 then 
              eval_exp e_then env
            else
              eval_exp e_else env
         | _ -> assert false (* type error *)
         )
  | LetExp(dec, e) ->
      let env' = eval_dec dec env in
        eval_exp e env'

and eval_assign lval v =
  match lval with LvalSimpl r -> (r := v)

and eval_exps es env =
 match es with
   [] -> []
 | e::es' ->
    let v = eval_exp e env in
    let vs = eval_exps es' env in
       v::vs

(* eval_dec: dec -> env -> env *)
and eval_dec dec env =
  match dec with
    FunctionDec(f,fields,_,e) -> 
       let oenv = ref [] in
       let closure = Fun( List.map (fun (x,_,_) -> x) fields  , e , oenv) in
       (oenv := extend_venv env [f] [closure] ; !oenv )
  | VarDec(x,_,_,e) -> 
       let v = eval_exp e env in
         extend_venv env [x] [v]

and update_fenv v env =
  match v with
   Fun(_,_,ref_env) ->
        (ref_env := env)
  | _ -> assert false
  
and lval_of_var var env =
  let (v,ty)=var in LvalSimpl(lookup_venv v env)

and eval_var var env = 
  let (v,ty)= var in !(lookup_venv v env)

let rec print_value v =
  match v with
    UNIT -> print_string "()"
  | INT(n) -> print_int n
  | STRING(s) -> print_string s
  | Fun(_,_,_) -> print_string "<func>"
  | Prim s -> print_string ("<primitive "^s^">")


(* main: exp -> value *)
let main exp = 
  let v = eval_exp exp init_env in
    (print_string "val it = "; print_value v; print_string "\n")

