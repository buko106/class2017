open Syntax

exception Unbound
       

let empty_env = []
let extend x v env = (x, v) :: env
let extend_rec xvs env = xvs @ env

let rec lookup x env =
  try List.assoc x env with Not_found -> raise Unbound

let rec ty_subst : subst -> ty -> ty = fun subst ty ->
  match ty with
  | TInt        -> TInt
  | TBool       -> TBool
  | TFun(t1,t2) -> TFun(ty_subst subst t1,ty_subst subst t2)
  | TVar a    -> 
     let rec sigma subst =
       match subst with
       | [] -> TVar a
       |(ai,t)::tl-> 
         if a=ai then
           t
         else
           sigma tl
     in sigma subst

let compose : subst -> subst -> subst = fun subst subst' ->
  (* かぶったものを取り除かないとやばい？？？ *)
  (List.map (fun (ai,ti) -> (ai,ty_subst subst ti)) subst')@subst

let rec occur : tyvar -> ty -> bool = fun a t ->
  match t with
  |TInt -> false
  |TBool-> false
  |TFun(t1,t2) -> occur a t1 || occur a t2
  |TVar b when a=b -> true
  |TVar b          -> false

let rec subst_all : (ty*ty) list -> tyvar -> ty -> (ty*ty) list =
  fun c a t -> let rec subst_rec : ty -> ty = fun ty ->
                 match ty with
                 |TInt -> TInt
                 |TBool-> TBool
                 |TFun (t1,t2) -> TFun (subst_rec t1,subst_rec t2)
                 |TVar b -> if a=b then t else TVar b
               in 
               List.map (fun (t1,t2) -> (subst_rec t1,subst_rec t2)) c
               
let rec ty_unify : (ty*ty) list -> subst = function 
  | [] -> []
  |(s,t)::c when s=t -> ty_unify c
  |(TFun(s,t),TFun(s',t'))::c -> ty_unify ((s,s')::(t,t')::c)
  |(TVar a,t)::c when false = occur a t ->
    compose (ty_unify (subst_all c a t)) [(a,t)]
  |(t,TVar a)::c when false = occur a t ->
    compose (ty_unify (subst_all c a t)) [(a,t)]
 (* ここでエラー処理をカッコ良くするとわかりやすい *) 
  |_ -> failwith "unification error"


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
      | VInt i1, VInt i2 when i2=0 -> raise (EvalErr "division by zero")
      | VInt i1, VInt i2 -> VInt (i1 / i2)
      | _ -> raise (EvalErr "int value was expected in '/'"))
  | EAnd (e1,e2) ->
     let v1 = eval_expr env e1 in
     let v2 = eval_expr env e2 in
     (match v1,v2 with
      | VBool b1, VBool b2 -> VBool (b1 && b2)
      | _ -> raise (EvalErr "bool value was expected in '&&'"))
  | EOr (e1,e2) ->
     let v1 = eval_expr env e1 in
     let v2 = eval_expr env e2 in
     (match v1,v2 with
      | VBool b1, VBool b2 -> VBool (b1 || b2)
      | _ -> raise (EvalErr "bool value was expected in '||'"))
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
  | ELet ( xe, e) ->
     eval_expr (extend_rec (List.map (fun (x,e)->(x,eval_expr env e)) xe)env ) e
  | ELetRec ( fxes ,e ) ->
     let oenv = ref [] in
     (oenv := (List.map (fun (f,x,e) -> (f,VFun(x,e,oenv))) fxes)@env ;
      eval_expr !oenv e)
  | EFun ( x , e) -> VFun ( x , e , ref env)
  | EApp ( f , e) -> 
     (match eval_expr env f  with
      | VFun ( x , body , fun_env ) -> eval_expr (extend x (eval_expr env e) !fun_env) body
      | _   -> raise (EvalErr "fun value was expected in 'apply'"))

let rec eval_topleveldec xe id_v env = (* eval for let..and..and *)
  match xe with
  | [] -> (id_v,extend_rec id_v env)
  |(x,e)::tl-> let v = eval_expr env e in
               eval_topleveldec tl ((x,v)::id_v) env

let rec eval_topleveldec_chain xe_s id_v env = (* eval for let..and..let and... *)
  let rec formatting id_v =
    let rec formatting_remove id_v x =
      match id_v with
      | [] -> []
      |(x',v)::tl when x'=x -> formatting_remove tl x
      |(x',v)::tl           -> (x',v) :: formatting_remove tl x
    in
    match id_v with
    | [] -> []
    |(x,v)::tl->("val "^x,v):: formatting (formatting_remove tl x)
  in
  match xe_s with
  | [] -> (formatting id_v,env)
  |hd::tl -> let (new_id_v,new_env) = eval_topleveldec hd id_v env in
             eval_topleveldec_chain tl new_id_v new_env

let rec eval_command env c =
  match c with
  | CExp e -> ([("-",eval_expr env e)], env)
  | CDecl xe_s -> eval_topleveldec_chain xe_s [] env
  | CRecDecl fxes ->
     let oenv = ref [] in
     (oenv := (List.map (fun (f,x,e) -> (f,VFun(x,e,oenv))) fxes)@env ;
      ( List.map (fun (f,_,_) -> ("val "^f,eval_expr !oenv (EVar f))) fxes ,!oenv))
  | CQuit -> raise Exit
