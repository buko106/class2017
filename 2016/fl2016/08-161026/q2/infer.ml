open Syntax

exception Unbound
exception InferErr of string

let empty_tyenv = []
let extend x v env = (x, v) :: env
let extend_rec xvs env = xvs @ env

let lookup x env =
  try List.assoc x env with Not_found -> raise Unbound

let num = ref 0
let new_tyvar () =
   num := !num + 1 ; !num

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
  (List.map (fun (ai,ti) -> (ai,ty_subst subst ti)) subst') @ subst

let rec occur : tyvar -> ty -> bool = fun a t -> (* If (TVar a) occurs in t *)
  match t with
  |TInt -> false
  |TBool-> false
  |TFun(t1,t2) -> occur a t1 || occur a t2
  |TVar b when a=b -> true
  |TVar b          -> false

let rec subst_rec : tyvar -> ty -> ty -> ty = fun a t ty -> (* ty[a:=t] *)
  match ty with
  |TInt -> TInt
  |TBool-> TBool
  |TFun (t1,t2) -> TFun (subst_rec a t t1,subst_rec a t t2)
  |TVar b -> if a=b then t else TVar b

let rec constraits_subst : constraints -> tyvar -> ty -> constraints = fun c a t -> (* c[a:=t] *)
  List.map (fun (t1,t2) -> (subst_rec a t t1,subst_rec a t t2)) c

let rec ty_unify : constraints -> subst = function (* solve constraits : c |-> sigma *)
  | [] -> []
  |(s,t)::c when s=t -> ty_unify c
  |(TFun(s,t),TFun(s',t'))::c -> ty_unify ((s,s')::(t,t')::c)
  |(TVar a,t)::c when false = occur a t ->
    compose (ty_unify (constraits_subst c a t)) [(a,t)]
  |(t,TVar a)::c when false = occur a t ->
    compose (ty_unify (constraits_subst c a t)) [(a,t)]
 (* ここでエラー処理をカッコ良くするとわかりやすい *) 
  |_ -> raise (InferErr "unification error")

let rec merge xs ys =  (* 重複しなようにマージ *)
  match (xs, ys) with
    ([], _) -> ys
  | (_, []) -> xs
  | (x1:: xtl, y1::ytl) ->
    if x1 < y1 then
      x1::merge xtl ys
    else if x1 = y1 then
      merge xs ytl
    else
      y1::merge xs ytl

let rec get_type_vars : ty -> tyvar list = fun ty -> (* ty |-> a|(TVar a) occurs in ty *)
  match ty with
  | TInt | TBool -> []
  | TFun (t1,t2) -> merge (get_type_vars t1) (get_type_vars t2)
  | TVar a -> [a]

let generalize : tyenv -> ty -> type_schema = fun tyenv ty -> (* 型変数が環境に出てこないならforallをつけて格上げ delta s -> forall P.s*)
  let tyvars = get_type_vars ty in
  (List.filter ( fun tyvar -> List.for_all ( fun ( _ ,( _ , ty )) -> not (occur tyvar ty) ) tyenv ) tyvars
  ,ty)

let tyenv_subst : subst -> tyenv -> tyenv = fun subst tyenv -> (* subst( tyenv ) *)
  match subst with
  | [] -> tyenv
  |(a,t)::subst' -> List.map (fun (name , (tyvars,ty)) -> if List.exists (fun tyvar -> tyvar = a) tyvars then 
                                                            (name,(tyvars,ty))
                                                          else
                                                            (name,(tyvars,subst_rec a t ty))
                             ) tyenv

let rec infer_expr : tyenv -> expr -> ty * constraints = fun tyenv e ->
  match e with
  | EConstInt  _ -> ( TInt , empty_tyenv )
  | EConstBool _ -> ( TBool, empty_tyenv )
  | EVar x       -> 
     (try
        let (forall,ty) = lookup x tyenv in
        (ty_subst (List.map (fun a-> (a,TVar (new_tyvar ()))) forall) ty
        ,empty_tyenv)
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
     let mapped_list= List.map (fun (x,e) -> (x,infer_expr tyenv e)) xe in
     let x_sigma_s_list=List.map (fun (x,(t,c))->
                                 let sigma = ty_unify c in
                                 let s     = ty_subst sigma t in
                                 (x,sigma,s)) mapped_list in
     let delta = List.fold_left (fun gamma (_,sigma,_) -> tyenv_subst sigma gamma) tyenv x_sigma_s_list in
     let new_tyenv =  (List.map (fun (x,_,s)->(x,generalize delta s)) x_sigma_s_list) @ delta in
     let (t_e,c_e)=infer_expr new_tyenv e in
     ( t_e , List.concat(c_e::(List.map (fun (_,(_,c))->c) mapped_list)) )
  | ELetRec (fxes,e) ->
     let mapped_list= List.map
                        (fun (f,x,e)->
                          let a = new_tyvar () in
                          let b = new_tyvar () in
                          (f,a,b,x,e)
                        ) fxes in
     let extended_tyenv = List.map (fun (f,a,b,_,_) -> (f,([],TFun(TVar a,TVar b)))) mapped_list @ tyenv in
     let mapped_t_c_b= List.map (fun (f,a,b,x,e)->(infer_expr ((x,([],TVar a))::extended_tyenv) e,b) ) mapped_list in
     let constraints = List.concat (List.map (fun ((t,c),b)->(t,TVar b)::c) mapped_t_c_b) in
     let subst = ty_unify constraints in
     let delta = tyenv_subst subst tyenv in 
     let newtyenv = List.map (fun (f,a,b,_,_) -> (f , generalize delta (ty_subst subst (TFun(TVar a,TVar b))))) mapped_list @ tyenv in
     let ( t_e , c_e ) = infer_expr newtyenv e in
     ( t_e , c_e @ constraints )
  | EFun (x,e)-> let a = new_tyvar () in
                 let new_tyenv = extend x ([],TVar a) tyenv in
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
               let sigma=ty_unify c in
               let s = ty_subst sigma t in
               infer_topleveldec tl ( (x,generalize (tyenv_subst sigma tyenv) s)::id_t ) tyenv

let rec infer_topleveldec_chain xe_s id_t tyenv =
  match xe_s with
  | [] ->  (id_t,tyenv)
  |hd::tl-> let (new_id_t,new_tyenv) = infer_topleveldec hd id_t tyenv in
            infer_topleveldec_chain tl new_id_t new_tyenv

