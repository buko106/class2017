open Syntax

type ty = TInt | TBool | TString | TList of ty list | TArrow of ty*ty

type tyenv = (string*ty) list

let rec tcheck e =
  match e with
  |IntLit _ -> TInt
