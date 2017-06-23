open Syntax

exception Unbound
exception EvalErr of string
exception InferErr of string
let empty_env = []
let extend x v env = (x, v) :: env
let extend_rec xvs env = xvs @ env

let lookup x env =
  try List.assoc x env with Not_found -> raise Unbound

let num = ref 0
let new_tyvar () =
   num := !num + 1 ; !num
    
(* type infering section *)
    
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

let rec subst_all : constraints -> tyvar -> ty -> constraints =
  fun c a t -> let rec subst_rec : ty -> ty = fun ty ->
                 match ty with
                 |TInt -> TInt
                 |TBool-> TBool
                 |TFun (t1,t2) -> TFun (subst_rec t1,subst_rec t2)
                 |TVar b -> if a=b then t else TVar b
               in 
               List.map (fun (t1,t2) -> (subst_rec t1,subst_rec t2)) c
               
let rec ty_unify : constraints -> subst = function 
  | [] -> []
  |(s,t)::c when s=t -> ty_unify c
  |(TFun(s,t),TFun(s',t'))::c -> ty_unify ((s,s')::(t,t')::c)
  |(TVar a,t)::c when false = occur a t ->
    compose (ty_unify (subst_all c a t)) [(a,t)]
  |(t,TVar a)::c when false = occur a t ->
    compose (ty_unify (subst_all c a t)) [(a,t)]
 (* ここでエラー処理をカッコ良くするとわかりやすい *) 
  |_ -> raise (InferErr "unification error")

let rec infer_expr : tyenv -> expr -> ty * constraints = fun tyenv e ->
  match e with
  | EConstInt  _ -> ( TInt , empty_env )
  | EConstBool _ -> ( TBool, empty_env )
  | EVar x       -> 
     (try
        let ty = lookup x tyenv in ( ty , empty_env )
      with
      | Unbound -> raise (InferErr "Unbound variable"))
  | EAdd (e1,e2) | ESub (e1,e2) | EMul (e1,e2) | EDiv (e1,e2)->
     let (t1,c1) = infer_expr tyenv e1 in
     let (t2,c2) = infer_expr tyenv e2 in
     ( TInt , (t1,TInt)::(t2,TInt)::c1@c2 )
  | EAnd (e1,e2) | EOr (e1,e2) ->
     let (t1,c1) = infer_expr tyenv e1 in
     let (t2,c2) = infer_expr tyenv e2 in
     ( TBool, (t1,TBool)::(t2,TBool)::c1@c2 )
  | EEq (e1,e2) | ELt (e1,e2) ->
     let (t1,c1) = infer_expr tyenv e1 in
     let (t2,c2) = infer_expr tyenv e2 in
     ( TBool, (t1,t2)::c1@c2 )
  | EIf (e1,e2,e3) ->
     let (t1,c1) = infer_expr tyenv e1 in
     let (t2,c2) = infer_expr tyenv e2 in
     let (t3,c3) = infer_expr tyenv e3 in
     ( t2 , (t1,TBool)::(t2,t3)::c1@c2@c3 )
  | ELet (xe,e) ->
     let mapped_list=(List.map (fun (x,e) -> (x,infer_expr tyenv e)) xe)in
     let new_tyenv=((List.map (fun (x,(t,_))->(x,t)) mapped_list)@tyenv)in
     let (t_e,c_e)=infer_expr new_tyenv e in
     ( t_e , List.concat(c_e::(List.map (fun (_,(_,c))->c) mapped_list)) )
  | ELetRec (fxes,e) ->
     let mapped_list= List.map
                        (fun (f,x,e)->
                          let a = new_tyvar () in
                          let b = new_tyvar () in
                          (f,a,b,x,e)
                        ) fxes in
     let new_tyenv = List.map (fun (f,a,b,_,_) -> (f,TFun(TVar a,TVar b))) mapped_list @ tyenv in
     let mapped_t_c_b= List.map (fun (f,a,b,x,e)->(infer_expr ((x,TVar a)::new_tyenv) e,b) ) mapped_list in
     let (t_e,c_e) = infer_expr new_tyenv e in
     ( t_e , c_e @ List.concat (List.map (fun ((t,c),b)->(t,TVar b)::c) mapped_t_c_b) )
  | EFun (x,e)-> let a = new_tyvar () in
                 let new_tyenv = extend x (TVar a) tyenv in
                 let (t,c) = infer_expr new_tyenv e in
                 ( TFun (TVar a,t) , c)
  | EApp (f,e)-> let (t1,c1) = infer_expr tyenv f in
                 let (t2,c2) = infer_expr tyenv e in
                 let a = new_tyvar () in
                 ( TVar a , (t1,TFun(t2,TVar a))::c1@c2 )
     
let rec infer_topleveldec xe id_t tyenv =
  match xe with
  | [] -> (id_t,extend_rec id_t tyenv)
  |(x,e)::tl-> let (t,c)=infer_expr tyenv e in
               infer_topleveldec tl ((x,ty_subst (ty_unify c) t)::id_t) tyenv

let rec infer_topleveldec_chain xe_s id_t tyenv =
  match xe_s with
  | [] ->  (id_t,tyenv)
  |hd::tl-> let (new_id_t,new_tyenv) = infer_topleveldec hd id_t tyenv in
            infer_topleveldec_chain tl new_id_t new_tyenv

let infer_cmd : tyenv -> command -> ty * tyenv = fun tyenv c ->
  match c with
  | CExp e -> let ( ty , constraints ) = infer_expr tyenv e in
             (ty_subst (ty_unify constraints) ty,tyenv)
  | CDecl xe_s ->let (_,new_tyenv)=infer_topleveldec_chain xe_s [] tyenv in
                 ( TInt (* dammy *) , new_tyenv )
  | CRecDecl fxes ->
     let mapped_list= List.map
                        (fun (f,x,e)->
                          let a = new_tyvar () in
                          let b = new_tyvar () in
                          (f,a,b,x,e)
                        ) fxes in
     let new_tyenv = List.map (fun (f,a,b,_,_) -> (f,TFun(TVar a,TVar b))) mapped_list @ tyenv in
     let mapped_t_c_b= List.map (fun (f,a,b,x,e)->(infer_expr ((x,TVar a)::new_tyenv) e,b) ) mapped_list in
     let mapped_constraints = List.concat (List.map (fun ((t,c),b)->(t,TVar b)::c) mapped_t_c_b) in
     let subst = ty_unify mapped_constraints in
     ( TInt , List.map (fun (f,a,b,_,_)->(f,ty_subst subst (TFun(TVar a,TVar b)))) mapped_list
              @tyenv)
  | CQuit -> raise Exit

(* eval section *)


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

let rec eval_topleveldec_chain xe_s id_v env tyenv= (* eval for let..and..let and... *)
  let rec formatting id_v =
    let rec formatting_remove id_v x =
      match id_v with
      | [] -> []
      |(x',v)::tl when x'=x -> formatting_remove tl x
      |(x',v)::tl           -> (x',v) :: formatting_remove tl x
    in
    match id_v with
    | [] -> []
    |(x,v)::tl->("val "^x^" : "^string_of_ty (lookup x tyenv),v):: formatting (formatting_remove tl x)
  in
  match xe_s with
  | [] -> (formatting id_v,env)
  |hd::tl -> let (new_id_v,new_env) = eval_topleveldec hd id_v env in
             eval_topleveldec_chain tl new_id_v new_env tyenv

let eval_command env tyenv c =
  match c with
  | CExp e ->
     let ( ty , constraints ) = infer_expr tyenv e in
     let t = ty_subst (ty_unify constraints) ty in
     ([("- : "^string_of_ty t,eval_expr env e)], env , tyenv)
  | CDecl xe_s ->
     let ( _ , newtyenv ) = infer_topleveldec_chain xe_s [] tyenv in
     let (msgs,newenv)=eval_topleveldec_chain xe_s [] env newtyenv in
     (msgs,newenv,newtyenv)
  | CRecDecl fxes ->
     let mapped_list= List.map
                        (fun (f,x,e)->
                          let a = new_tyvar () in
                          let b = new_tyvar () in
                          (f,a,b,x,e)
                        ) fxes in
     let extended_tyenv = List.map (fun (f,a,b,_,_) -> (f,TFun(TVar a,TVar b))) mapped_list @ tyenv in
     let mapped_t_c_b= List.map (fun (f,a,b,x,e)->(infer_expr ((x,TVar a)::extended_tyenv) e,b) ) mapped_list in
     let mapped_constraints = List.concat (List.map (fun ((t,c),b)->(t,TVar b)::c) mapped_t_c_b) in
     let subst = ty_unify mapped_constraints in
     let newtyenv =
       List.map (fun (f,a,b,_,_)->(f,ty_subst subst (TFun(TVar a,TVar b)))) mapped_list@tyenv in
     let oenv = ref [] in
     let (msgs,newenv) = (oenv := (List.map (fun (f,x,e) -> (f,VFun(x,e,oenv))) fxes)@env ;( List.map (fun (f,_,_) -> ("val "^f^" : "^string_of_ty (lookup f newtyenv),eval_expr !oenv (EVar f))) fxes ,!oenv)) in (List.rev msgs,newenv,newtyenv)
  | CQuit -> raise Exit
