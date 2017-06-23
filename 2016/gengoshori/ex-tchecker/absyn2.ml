type pos = int*int (* (line number, column) *)
type symbol = string 
let name_of_symbol (v,_) = v

type var = symbol * ty

and exp = 
   VarExp of var 
 | NilExp
 | IntExp of int
 | StringExp of string 
 | CallExp of symbol * exp list
 | OpExp of exp * op * exp
 | SeqExp of exp list
 | AssignExp of var * exp
 | IfExp of exp * exp * exp 
 | LetExp of dec * exp (* we consider only a single declaration *)

and dec = 
  VarDec of vardec
| FunctionDec of fundec 

and vardec = symbol * bool ref * ty * exp
and fundec = symbol * field list * ty * exp 

and ty = Absyn.ty

and op = oper * ty
and oper = Absyn.oper

and field = symbol * bool ref * ty

