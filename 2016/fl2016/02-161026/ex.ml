type complex = { re : float ; im : float }

type iexpr =
  | EConstInt of int
  | EAdd        of iexpr * iexpr
  | ESub        of iexpr * iexpr
  | EMul        of iexpr * iexpr

let rec eval e =
  match e with
  |EConstInt x -> x
  |EAdd (x,y)  -> (eval x) + (eval y)
  |ESub (x,y)  -> (eval x) - (eval y)
  |EMul (x,y)  -> (eval x) * (eval y)

