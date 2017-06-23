open Syntax
(* begin environment functions *)                            
let (emptyenv:unit->env) = fun () -> []

let (ext:env->string->value->env) = fun env x v -> (x,v) :: env

let rec (lookup:string->env->value) = fun x env ->
  match env with
  |[] -> failwith ("unbound variable:" ^ x)
  |(y,v)::tl -> if x=y then
                  v
                else
                  lookup x tl
(* end environment functions *)




(* begin eval *)                            
let rec (eval:exp->env->value)= fun e env ->
  let i2i2ieval f e1 e2 =
    match (eval e2 env,eval e1 env) with
    |(IntVal n2,IntVal n1)-> IntVal (f n1 n2)
    | _ -> failwith "integer value expected"
  in
  let i2i2beval f e1 e2 =
    match (eval e2 env,eval e1 env) with
    |(IntVal n2,IntVal n1)-> BoolVal (f n1 n2)
    | _ -> failwith "integer value expected"
  in
  let rec eqeval e1 e2 =
    match (eval e2 env,eval e1 env) with
    |(IntVal n2,IntVal n1) -> BoolVal (n1=n2)
    |(BoolVal b2,BoolVal b1) -> BoolVal (b1=b2)
    |(StringVal s2,StringVal s1) -> BoolVal (s1=s2)
    |(ListVal l2,ListVal l1) -> BoolVal (l1=l2)
    | _ -> failwith "'=' expects same type of values"
  in
  let ifeval e1 e2 e3 =
    match eval e1 env with
    |BoolVal true  -> eval e2 env
    |BoolVal false -> eval e3 env
    | _ -> failwith "'if' expects Bool value"
  in
  let appeval e1 e2 =
    let arg = eval e2 env in
    let funpart = eval e1 env in
    match funpart with
    |FunVal (x,body,env1) ->
      eval body (ext env1 x arg)
    |RecFunVal (f,x,body,env1) ->
      eval body (ext (ext env1 x arg) f funpart)
    | _ ->
       failwith "wrong value in App"
  in

  match e with
  |Var x -> lookup x env
  |IntLit n -> IntVal n
  |BoolLit b -> BoolVal b
  |If (e1,e2,e3) -> ifeval e1 e2 e3
  |Let (x,e1,e2) -> eval e2 (ext env x (eval e1 env))
  |LetRec (f,x,e1,e2) -> eval e2 (ext env f (RecFunVal (f,x,e1,env)))
  |Fun (x,e1) -> FunVal (x,e1,env)
  |App (e1,e2) -> appeval e1 e2
  |Eq (e1,e2) -> eqeval e1 e2
  |Greater (e1,e2) -> i2i2beval ( > ) e1 e2
  |Less (e1,e2) -> i2i2beval ( < ) e1 e2
  |Plus (e1,e2) -> i2i2ieval ( + ) e1 e2
  |Minus (e1,e2) -> i2i2ieval ( - ) e1 e2
  |Times (e1,e2) -> i2i2ieval ( * ) e1 e2
  |Div (e1,e2) -> i2i2ieval ( / ) e1 e2
  |Empty -> ListVal []
  |Cons (e1,e2) ->
    begin
      match (eval e2 env,eval e1 env) with
      |(ListVal v2,v1) -> ListVal (v1::v2)
      | _ -> failwith "'::' expects list"
    end
  |Head e1 ->
    begin
      match eval e1 env with
      |ListVal (x::_) -> x
      | _ -> failwith "\"List.hd\" expects non-empty list"
    end
  |Tail e1 ->
    begin
      match eval e1 env with
      |ListVal (_::xs) -> ListVal xs
      | _ -> failwith "\"List.tl\" expects non-empty list"
    end
  (* | _ -> failwith "unknown expression"  *)

(* end eval *)


(* begin print functions *)
let rec string_of_exp e =
  match e with
  |Var x -> x
  |IntLit n -> string_of_int n
  |BoolLit b -> if b then "true" else "false"
  |If (e1,e2,e3) -> "if " ^ string_of_exp e1 ^ " then " ^ string_of_exp e2 ^ " else " ^ string_of_exp e3
  |Let (x,e1,e2) -> "let " ^ x ^ " = " ^ string_of_exp e1 ^ " in " ^ string_of_exp e2
  |LetRec (f,x,e1,e2) -> "let rec " ^ f ^ " " ^ x ^ " = " ^ string_of_exp e1 ^ " in " ^ string_of_exp e2
  |Fun (x,e1) -> "'(fun " ^ x ^ " -> " ^ string_of_exp e1 ^ ")"
  |App (e1,e2) -> string_of_exp e1 ^ " " ^ string_of_exp e2
  |Eq (e1,e2) -> string_of_exp e1 ^ "=" ^ string_of_exp e2
  |Greater(e1,e2)-> string_of_exp e1 ^ ">" ^ string_of_exp e2
  |Less (e1,e2) ->  string_of_exp e1 ^ "<" ^ string_of_exp e2
  |Plus (e1,e2) -> "(" ^ string_of_exp e1 ^ "+" ^ string_of_exp e2 ^ ")"
  |Minus(e1,e2) -> "(" ^ string_of_exp e1 ^ "-" ^ string_of_exp e2 ^ ")"
  |Times(e1,e2) -> "(" ^ string_of_exp e1 ^ "*" ^ string_of_exp e2 ^ ")"
  |Div  (e1,e2) -> "(" ^ string_of_exp e1 ^ "/" ^ string_of_exp e2 ^ ")"
  |Empty -> "[]"
  |Cons (e1,e2) -> string_of_exp e1 ^ "::" ^ string_of_exp e2
  |Head e1 -> "List.hd " ^ string_of_exp e1
  (* | _ -> failwith "unknown expression" *)

let rec string_of_val v =
  match v with
  |IntVal n -> string_of_int n
  |BoolVal b -> string_of_bool b
  |ListVal l -> "[" ^ string_of_list l ^ "]"
  |StringVal s -> "\"" ^ s ^ "\""
  |FunVal _ -> "<fun>"
  |RecFunVal _ -> "<fun>"
and string_of_list l =
  let rec string_of_list_tailrec l ret =
    match l with
    | [] -> ret
    |hd::tl -> string_of_list_tailrec tl (string_of_val hd ^ "; " ^ ret)
  in string_of_list_tailrec l ""
                            
