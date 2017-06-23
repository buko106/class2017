type exp = 
  |IntLit of int
  |Plus of exp*exp
  |Times of exp*exp
  |BoolLit of bool
  |If of exp*exp*exp
  |Eq of exp*exp

type value=
  |IntVal of int
  |BoolVal of bool
  |StringVal of string
  |ListVal of value list
  |FunVal of string * exp * env
