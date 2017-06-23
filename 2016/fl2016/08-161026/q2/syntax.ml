type name = string 

type tyvar = int

type ty =
  | TInt
  | TBool
  | TFun of ty * ty
  | TVar of tyvar

type type_schema = tyvar list * ty
type subst = (tyvar * ty) list
type constraints = (ty * ty) list
type tyenv = (name * type_schema) list

type value =
  | VInt  of int
  | VBool of bool
  | VFun  of name * expr * env ref
and expr =
  | EConstInt  of int
  | EConstBool of bool
  | EVar       of name 
  | EAdd       of expr * expr
  | ESub       of expr * expr
  | EMul       of expr * expr
  | EDiv       of expr * expr
  | EAnd       of expr * expr
  | EOr        of expr * expr
  | EEq        of expr * expr
  | ELt        of expr * expr		 
  | EIf        of expr * expr * expr
  | ELet       of (name * expr) list * expr
  | ELetRec    of (name * name * expr) list * expr
  | EFun       of name * expr
  | EApp       of expr * expr
and env = (name * value) list

			   
type command =
  | CExp  of expr
  | CDecl of (name * expr) list list
  | CRecDecl of (name * name * expr) list
  | CNil
  | CQuit
				  
let print_name = print_string 

let print_value v =
  match v with
  | VInt i  -> print_int i
  | VBool b -> print_string (string_of_bool b)
  | VFun (_,_,_) -> print_string "<fun>"
                                 
let rec string_of_ty ((forall_list,ty): type_schema) =
  let rec insert l i =
    match l with
    | []    -> [i]
    |hd::tl -> if i < hd then
                 i :: hd :: tl
               else  if i = hd then 
                 hd :: tl
               else (* i > hd*)
                 hd :: insert tl i 
  in
  let rec list_up_tvar l1 ty = 
    match ty with
    | TInt -> l1
    | TBool-> l1
    | TFun(t1,t2)-> let l2 = list_up_tvar l1 t1 in list_up_tvar l2 t2
    | TVar i -> insert l1 i 
  in
  let sorted = list_up_tvar [] ty in
  let rec numbering l n =
    match l with
    | [] -> []
    |hd::tl -> (hd,n):: numbering tl (n+1)
  in
  let i2n = numbering sorted 0 in
  let rec string_of_number n =
    if n<26 then
      String.make 1 (char_of_int (n+97))
    else
      (string_of_number (n/26-1)) ^ (string_of_number (n mod 26))
  in
  let rec string_of_ty_sub ty paren =
    match ty with
    | TInt -> "int"
    | TBool-> "bool"
    | TFun (t1,t2)->
       (if paren then "(" else "") ^ string_of_ty_sub t1 true ^ " -> " ^ string_of_ty_sub t2 false ^(if paren then ")" else "")
    | TVar i ->
       "'" ^ ( string_of_number (List.assoc i i2n)  )
  in String.concat "" (List.map (fun a-> "'" ^ string_of_number (List.assoc a i2n) ^".") forall_list)^string_of_ty_sub ty (if forall_list = [] then false else true)
(*
 小さい式に対しては以下でも問題はないが，
 大きいサイズの式を見やすく表示したければ，Formatモジュール
   http://caml.inria.fr/pub/docs/manual-ocaml/libref/Format.html
 を活用すること
*)
let rec print_expr e =
  match e with
  | EConstInt i ->
     print_int i
  | EConstBool b ->
     print_string (string_of_bool b)
  | EVar x -> 
     print_name x
  | EAdd (e1,e2) -> 
     (print_string "EAdd (";
      print_expr e1;
      print_string ",";
      print_expr e2;
      print_string ")")
  | ESub (e1,e2) -> 
     (print_string "ESub (";
      print_expr e1;
      print_string ",";
      print_expr e2;
      print_string ")")
  | EMul (e1,e2) -> 
     (print_string "EMul (";
      print_expr e1;
      print_string ",";
      print_expr e2;
      print_string ")")
  | EDiv (e1,e2) -> 
     (print_string "EDiv (";
      print_expr e1;
      print_string ",";
      print_expr e2;
      print_string ")")
  | EAnd (e1,e2) ->
     (print_string "EAnd (";
      print_expr e1;
      print_string ",";
      print_expr e2;
      print_string ")")
  | EOr (e1,e2) ->
     (print_string "EOr (";
      print_expr e1;
      print_string ",";
      print_expr e2;
      print_string ")")
  | EEq (e1,e2) ->
     (print_string "EEq (";
      print_expr e1;
      print_string ",";
      print_expr e2;
      print_string ")")
  | ELt (e1, e2) ->
     (print_string "ELt (";
      print_expr e1;
      print_string ",";
      print_expr e2;
      print_string ")")
  | EIf (e1,e2,e3) ->
     (print_string "EIf (";
      print_expr   e1;
      print_string ","; 
      print_expr   e2;
      print_string ",";
      print_expr   e3;
      print_string ")")

let rec print_command p =       
  match p with
  | CExp e -> print_expr e
