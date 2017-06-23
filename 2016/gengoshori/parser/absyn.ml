type pos = int*int (* (line number, column) *)
type symbol = string * pos

type var = symbol 

and exp = 
   VarExp of var
 | NilExp
 | IntExp of int
 | StringExp of string 
 | CallExp of symbol * exp list
 | OpExp of exp * op * exp
 | SeqExp of exp list
 | AssignExp of var * exp
 | IfExp of exp * exp * exp option
 | LetExp of dec * exp (* we consider only a single declaration *)

and dec = 
  VarDec of vardec
| FunctionDec of fundec 

and vardec = symbol * bool ref * ty option * exp
and fundec = symbol * field list * ty option * exp 

and ty = IntTy | StringTy | UnitTy

and op = oper * pos
and oper =
  PlusOp | MinusOp | TimesOp | DivideOp
| EqOp | NeqOp | LtOp | LeOp 

and field = symbol * bool ref * ty

