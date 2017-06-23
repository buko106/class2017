open Syntax
open Infer

exception Unbound
exception EvalErr of string

let empty_env = []
let extend x v env = (x, v) :: env
let extend_rec xvs env = xvs @ env

let lookup x env =
  try List.assoc x env with Not_found -> raise Unbound



let rec find_match : pattern -> value ->  (name * value) list option = fun p v ->
  match ( p , v ) with
  | (PVar a , v ) -> Some [(a,v)]
  | (PInt x , VInt y) when x=y -> Some []
  | (PBool x, VBool y) when x=y-> Some []
  | (PPair (p1,p2), VPair(v1,v2)) ->
     (match ( find_match p1 v1 , find_match p2 v2) with
      |(Some xvs1,Some xvs2)-> Some  ( xvs1 @ xvs2 )
      | _ -> None)
  | (PNil , VNil) -> Some []
  | (PCons (p1,p2) , VCons (v1,v2))->
     (match ( find_match p1 v1 , find_match p2 v2) with
      |(Some xvs1,Some xvs2)-> Some  ( xvs1 @ xvs2 )
      | _ -> None)
  | _ -> None
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
  | EMatch ( e , pes ) ->
     let v = eval_expr env e in
     (match List.concat (List.map
                          (fun (p,e) ->
                            match find_match p v with
                            | Some xvs -> [(xvs,e)]
                            | None -> []
                          ) pes) with
     | [] -> raise (EvalErr "match failure")
     | (xvs,e')::_ -> eval_expr (extend_rec env xvs) e')
  | EPair ( e1 , e2 ) -> VPair (eval_expr env e1 ,eval_expr env e2)
  | ENil -> VNil
  | ECons ( e1 , e2 ) -> 
     let v1 = eval_expr env e1 in
     let v2 = eval_expr env e2 in
     VCons ( v1 , v2 )
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
     ([("- : "^string_of_ty (generalize tyenv t),eval_expr env e)], env , tyenv)
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
     let extended_tyenv = List.map (fun (f,a,b,_,_) -> (f,([],TFun(TVar a,TVar b)))) mapped_list @ tyenv in
     let mapped_t_c_b= List.map (fun (f,a,b,x,e)->(infer_expr ((x,([],TVar a))::extended_tyenv) e,b) ) mapped_list in
     let constraints = List.concat (List.map (fun ((t,c),b)->(t,TVar b)::c) mapped_t_c_b) in
     let subst = ty_unify constraints in
     let delta = tyenv_subst subst tyenv in 
     let newtyenv = List.map (fun (f,a,b,_,_) -> (f , generalize delta (ty_subst subst (TFun(TVar a,TVar b))))) mapped_list @ tyenv in
     let oenv = ref [] in
     let (msgs,newenv) = (oenv := (List.map (fun (f,x,e) -> (f,VFun(x,e,oenv))) fxes)@env ;( List.map (fun (f,_,_) -> ("val "^f^" : "^string_of_ty (lookup f newtyenv),eval_expr !oenv (EVar f))) fxes ,!oenv)) in (List.rev msgs,newenv,newtyenv)
  | CNil  -> ( [] , env , tyenv )
  | CQuit -> raise Exit
