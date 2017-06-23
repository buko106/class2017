open Absyn

type level = int
(* an environment that maps a variable to
   a pair of its unique name and type *)
type env = (string * (string * vty)) list
      
and vty = Bty of Absyn.ty             (* base type *)
        | Fty of Absyn.ty list * ty  (* function type *)


(* for error messages *)
let report s = print_string (s^"\n")
let string_of_pos (line,col) =
  " at line "^(string_of_int line)^" col "^(string_of_int col)
(* utility function, which returns the last element of a list *)
let rec list_last l =
  match l with
    [] -> assert false
  | [x] -> x
  | x::l' -> list_last l'


let pos2string (line,column) =
  (string_of_int line)^"_"^(string_of_int column)

(* functions to extend type environments *)
(* add type binding v:ty *)
let extend_tenv_v (v,pos) ty env = 
  let v' = v^"@"^(pos2string pos) in
     (v, (v',Bty ty))::env

(* add type binding f:fty *)
let extend_tenv_f (f,pos) (argty,rty) env =
  let f' = f^"@"^(pos2string pos) in
    (f,(f',Fty(argty,rty)))::env

(* add type bindings venv_new *)
let extend_tenv_vs env1 env2 =
   env1@env2

let name_of_sym (v,pos)=v

(* lookup the type of a variable *)
let lookup_var (v,pos) env =
  try 
    match List.assoc v env with
       (v', Bty ty) -> (v',ty)
     | _ -> ( report ("The function "^v^(string_of_pos pos)^" is used as a variable\n");
             assert false)
  with Not_found -> report ("Undefined variable: "^v^(string_of_pos pos)); assert false

let lookup_fun (f,pos) env =
  try 
   match List.assoc f env with
       (v', Fty (argty,rty)) -> (v',(argty,rty))
     | _ -> ( report ("The variable "^f^(string_of_pos pos)^" is used as a function\n");
             assert false)

  with Not_found -> report ("Undefined function: "^f^(string_of_pos pos)); assert false

(* construct a function type from formal parameters and return type of a function declaration *)
let get_fty fields tyopt =
  let argtys = List.map (fun (_,_,ty)->ty) fields in
  let rty = 
    match tyopt with
     Some(rty) -> rty
    | None -> UnitTy
  in
     (argtys, rty)

let get_argenv args =
  List.map (fun ((x,pos),_,ty) -> (x, (x^"@"^(pos2string pos), Bty ty))) args

(* lookup the return type of operation op, given arguments of types ty1 and ty2 *)
let lookup_op op ty1 ty2 =
  let (opname,pos) = op in
    match opname with
     (Absyn.PlusOp|Absyn.MinusOp|Absyn.TimesOp|Absyn.DivideOp) -> 
        if ty1=IntTy && ty2=IntTy then 
            ((opname,IntTy), IntTy)
        else 
          (report ("Type error in operation at "^(string_of_pos pos));
           assert false)
    | (Absyn.EqOp | Absyn.NeqOp | Absyn.LtOp | Absyn.LeOp) ->
        if ty1=ty2 then ((opname,ty1), IntTy)
        else
          (report ("Type error in operation at "^(string_of_pos pos));
           assert false)

(* main functions for type checking 
   tcheck: Absyn.exp -> tenv -> Absyn2.exp * Absyn2.ty
   tcheckD: Absyn.dec -> tenv -> Absyn2.dec * tenv
*)
let rec tcheck (exp:Absyn.exp) (tenv: env): Absyn2.exp * Absyn2.ty =
  match exp with
    VarExp(v) -> let (v',ty) = lookup_var v tenv in 
                   (Absyn2.VarExp(v',ty), ty)
  | NilExp -> (Absyn2.NilExp, UnitTy)
  | IntExp n -> (Absyn2.IntExp n, IntTy)
  | StringExp s -> (Absyn2.StringExp s, StringTy)
  | CallExp(f,exps) ->
     let (f',(tys, retty)) = lookup_fun f tenv in
     let exp_tys = List.map (fun exp-> tcheck exp tenv) exps in
       if tys= (List.map snd exp_tys) then 
         (Absyn2.CallExp(f', List.map fst exp_tys), retty )
       else (report ("Type mismatch in function call "^(fst f)^
                    (string_of_pos (snd f)));assert false)
  | OpExp(exp1,op,exp2) ->
      let (exp1',ty1) = tcheck exp1 tenv in
      let (exp2',ty2) = tcheck exp2 tenv in
      let (op',ty) = lookup_op op ty1 ty2 in
        (Absyn2.OpExp(exp1',op',exp2'), ty)
  | SeqExp(exps) ->
     (* omit to check that expressions except the last one should have 
        type UnitTy *)
      let exp_tys = List.map (fun exp-> tcheck exp tenv) exps in
      let (exps',tys) = List.split exp_tys in
       ( match tys with
           [] -> (Absyn2.SeqExp(exps'),UnitTy)
         | _ -> (Absyn2.SeqExp(exps'),list_last tys)
        )
  | AssignExp(v, exp) ->
      let (v',ty_left) = lookup_var v tenv in
      let (exp',ty_right) = tcheck exp tenv in
        if ty_left=ty_right then 
          (Absyn2.AssignExp((v',ty_left),exp'), UnitTy)
        else 
         (report ("assignment to variable "^(fst v)^(string_of_pos (snd v)));
          assert false)
  | IfExp(exp_cond,exp_then,exp_else_opt) ->
      let (exp_cond',ty_cond) = tcheck exp_cond tenv in
      let (exp_then',ty_then) = tcheck exp_then tenv in
      let (exp_else',ty_else) = 
         match exp_else_opt with
           Some(exp_else) -> 
                tcheck exp_else tenv 
         | None -> (Absyn2.NilExp, UnitTy)
      in
        if ty_cond=IntTy && ty_then=ty_else then 
          (Absyn2.IfExp(exp_cond',exp_then',exp_else'), ty_then)
        else (report "type error in if-statement"; assert false)
  | LetExp(dec, exp) ->
      let (dec',tenv') = tcheck_dec dec tenv in
      let (exp', ty) = tcheck exp tenv' in
        (Absyn2.LetExp(dec', exp'), ty)

and tcheck_dec dec tenv =
 match dec with
   VarDec(v, flag, ty_opt, exp) -> 
     let (exp',ty) = tcheck exp tenv in
     let _ = match ty_opt with
                Some(ty') -> 
                 if ty=ty' then () 
                 else (report ("type error in variable declaration"^
                               (string_of_pos (snd v))); assert false)
              | _ -> ()
     in
     let tenv' =  extend_tenv_v v ty tenv in
     let (v',_) = lookup_var v tenv' in
       (Absyn2.VarDec(v', flag, ty, exp'), tenv')
 | FunctionDec(f, args, tyopt, exp) -> 
     let (tys,rty) = get_fty args tyopt in 
           (* tys = types of formal parameters, rty = the type of a return value *)
     let argenv = get_argenv args in
           (* argenv = type bindings x1:t1,...xn:tn on formal parameters *)
     let tenv' = extend_tenv_f f (tys,rty) tenv in
           (* tenv' = tenv, f: tys->rty *)
     let (f',_) = lookup_fun f tenv' in
     let tenv'' = extend_tenv_vs argenv tenv' in
           (* tenv'' = tenv, f: tys->rty, x1:t1,...,xn:tn *)
     let args' = List.map (fun (v,r,ty)->
                      let (v',_) = lookup_var v argenv in
                      (v',r,ty)) args in
     let (exp', rty') = tcheck exp tenv'' in
       if rty=rty' then
           (Absyn2.FunctionDec(f',args',rty,exp'), tenv')
       else
           (report ("type error in function declaration"
                   ^(string_of_pos (snd f))); assert false)

(* initial type environments *)
let init_tenv = (* types of standard library functions *)
  [("print", ("print", Fty([StringTy], UnitTy)));
   ("flush", ("flush", Fty(([], UnitTy))));
   ("getchar", ("getchar",Fty([], StringTy)));
   ("ord", ("ord", Fty([StringTy], IntTy)));
   ("chr", ("chr", Fty([IntTy], StringTy)));
   ("size", ("size",Fty([StringTy], IntTy)));
   ("substring", ("substring", Fty([StringTy;IntTy;IntTy], StringTy)));
   ("concat", ("concat",Fty([StringTy;StringTy], StringTy)));
   ("not", ("not",Fty([IntTy], IntTy)));
   ("exit", ("exit",Fty([IntTy], UnitTy)))]



let main exp =
  tcheck exp init_tenv