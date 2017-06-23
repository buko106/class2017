type t = (* MinCaml�η���ɽ������ǡ����� (caml2html: type_t) *)
  | Unit
  | Bool
  | Int
  | Float
  | Fun of t list * t (* arguments are uncurried *)
  | Tuple of t list
  | Array of t
  | Var of t option ref

let gentyp () = Var(ref None) (* ���������ѿ����� *)

let rec print_type t = 
  match t with
  | Unit -> print_string "Unit"
  | Bool -> print_string "Bool"
  | Int  -> print_string "Int"
  | Float-> print_string "Float"
  | Fun (tlist,t) -> (print_string "Fun(";
                      List.map (fun t->print_type t;print_string "->") tlist;
                      print_type t;
                      print_string ")"
                     )
  | Tuple tlist -> (print_string "Tuple( " ;List.map (fun t->print_type t;print_string " ") tlist ; print_string ")")
  | Array t -> (print_string "Array(" ; print_type t ; print_string ")")
  | Var reft -> (print_string "Var(" ;
                 (match !reft with Some t -> print_type t | None -> print_string "_") ; print_string ")")
