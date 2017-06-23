open Syntax

exception Unbound
       

let empty_env = []
let extend x v env = (x, v) :: env
let extend_rec xvs env = xvs @ env

let rec lookup x env =
  try List.assoc x env with Not_found -> raise Unbound

exception EvalErr of string

let rec eval_expr env e =
  match e with
  | EConstInt i ->
     VInt i
  | EConstBool b ->
     VBool b
  | EVar x ->
     (try
	 lookup x env
       with
       | Unbound -> raise (EvalErr "Unbound variable"))
  | EAdd (e1,e2) ->
     let v1 = eval_expr env e1 in
     let v2 = eval_expr env e2 in
     (match v1, v2 with
      | VInt i1, VInt i2 -> VInt (i1 + i2)
      | _ -> raise (EvalErr "int value was expected in '+'")) 
  | ESub (e1,e2) ->
     let v1 = eval_expr env e1 in
     let v2 = eval_expr env e2 in
     (match v1, v2 with
      | VInt i1, VInt i2 -> VInt (i1 - i2)
      | _ -> raise (EvalErr "int value was expected in '-'")) 
  | EMul (e1,e2) ->
     let v1 = eval_expr env e1 in
     let v2 = eval_expr env e2 in
     (match v1, v2 with
      | VInt i1, VInt i2 -> VInt (i1 * i2)
      | _ -> raise (EvalErr "int value was expected in '*'"))
  | EDiv (e1,e2) ->
     let v1 = eval_expr env e1 in
     let v2 = eval_expr env e2 in
     (match v1, v2 with
      | VInt i1, VInt i2  -> VInt (i1 / i2)
      | _ -> raise (EvalErr "int value was expected in '/'"))
  | EEq (e1,e2) ->
     let v1 = eval_expr env e1 in
     let v2 = eval_expr env e2 in
     (match v1, v2 with
      | VInt i1, VInt i2 -> VBool (i1 = i2)
      | VBool b1,VBool b2 ->VBool (b1 = b2)
      | _ -> raise (EvalErr "same type was expected in '='"))
  | ELt (e1,e2) ->
     let v1 = eval_expr env e1 in
     let v2 = eval_expr env e2 in
     (match v1, v2 with
      | VInt i1, VInt i2 -> VBool (i1 < i2)
      | VBool b1,VBool b2-> VBool (b1 < b2)
      | _ -> raise (EvalErr "same type was expected in '<'"))
  | EIf (e1,e2,e3) ->
     let v1 = eval_expr env e1 in
     (match v1 with
      | VBool b ->
	 if b then eval_expr env e2 else eval_expr env e3
      | _ -> raise (EvalErr "bool value was expected in 'if'"))
  | ELet ( x , e1, e2) ->
     eval_expr (extend x (eval_expr env e1) env) e2
  | EFun ( x , e) -> VFun ( x , e ,  env)
  | EApp ( f , e) -> 
     (match eval_expr env f  with
      | VFun ( x , body , fun_env ) ->
         eval_expr (extend x (eval_expr env e) fun_env) body
      | VRecFun ( f , x , body , fun_env ) ->
         let new_env = extend x (eval_expr env e)
                              (extend f (VRecFun ( f , x , body , fun_env)) fun_env) in
         eval_expr new_env body
      | _   -> raise (EvalErr "fun value was expected in 'apply'"))
  | ELetRec ( f , x , e1 , e2 ) ->
     let new_env = extend f (VRecFun(f,x,e1,env)) env
     in eval_expr new_env e2



let rec eval_command env c =
  match c with
  | CExp e -> ("-" , env , eval_expr  env  e)
  | CDecl (x,e) -> let v = eval_expr  env e in
                   ("val "^x,extend x v env,v)
