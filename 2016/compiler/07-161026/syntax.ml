type t = (* MinCamlの構文を表現するデータ型 (caml2html: syntax_t) *)
  | Unit
  | Bool of bool
  | Int of int
  | Float of float
  | Not of t
  | Neg of t
  | Add of t * t
  | Sub of t * t
  | Add_poly of t * t
  | Sub_poly of t * t
  | FNeg of t
  | FAdd of t * t
  | FSub of t * t
  | FMul of t * t
  | FDiv of t * t
  | Eq of t * t
  | LE of t * t
  | If of t * t * t
  | Let of (Id.t * Type.t) * t * t
  | Var of Id.t
  | LetRec of fundef * t
  | App of t * t list
  | Tuple of t list
  | LetTuple of (Id.t * Type.t) list * t * t
  | Array of t * t
  | Get of t * t
  | Put of t * t * t
and fundef = { name : Id.t * Type.t; args : (Id.t * Type.t) list; body : t }

let print_space n = print_string (String.make (2*n) ' ')

let rec print t n =
  (
  match t with
  | Unit -> (print_space n ; print_string "Unit")
  | Bool b -> (print_space n;print_string (if b then "Bool true" else "Bool false"))
  | Int i -> (print_space n;
              print_string "Int ";
              print_int i)
  | Float f -> (print_space n;
                print_string "Float ";
                print_float f)
  | Not t -> print_t t n "Not"
  | Neg t -> print_t t n "Neg"
  | Add (s,t) -> print_st s t n "Add"
  | Sub (s,t) -> print_st s t n "Sub"
  | Add_poly (s,t) -> print_st s t n "Add_poly"
  | Sub_poly (s,t) -> print_st s t n "Sub_poly"
  | FNeg t -> print_t t n "FNeg"
  | FAdd (s,t)-> print_st s t n "FAdd"
  | FSub (s,t)-> print_st s t n "FSub"
  | FMul (s,t)-> print_st s t n "FMul"
  | FDiv (s,t)-> print_st s t n "FDiv"
  | Eq (s,t)-> print_st s t n "Eq"
  | LE (s,t)-> print_st s t n "LE"
  | If (s,t,u)-> print_stu s t u n "If"
  | Let ((id,ty),s,t) -> (print_space n;
                          print_string "Let\n";
                          print_space (n+1);
                          print_string (id^":");
                          Type.print_type ty;
                          print_string "\n";
                          print s (n+1);
                          print_string "\n";
                          print t (n+1);
                         )
  | Var id -> (print_space n;print_string ("Var "^id))
  | LetRec (fundef,t) -> (print_space n;
                          print_string "LetRec\n";
                          print_space (n+1) ;
                          print_id_type fundef.name;
                          print_string "\n";
                          print_space (n+1);
                          List.map (fun idt->print_id_type idt;print_string " ") fundef.args;
                          print_string "\n";
                          print fundef.body (n+1);
                          print_string "\n" ;
                          print t (n+1))
  | App (t,tlist) -> (print_space n;
                      print_string "App\n";
                      print t (n+1);
                      print_string "\n";
                      List.map (fun t->print t (n+1)) tlist;
                      ())
  | Tuple tlist -> (print_space n;
                    print_string "Tuple \n";
                    List.map (fun t->print t (n+1);print_string "\n") tlist;
                    print_space n;
                    print_string "endTuple")
  | LetTuple (idtlist,s,t) -> (print_space n;
                               print_string "LetTuple\n" ;
                               print_space (n+1);
                               List.map (fun x->print_id_type x ; print_string " " ) idtlist ;
                               print_string "\n";
                               print s (n+1);
                               print_string "\n";
                               print t (n+1))
  | Array (s,t) -> print_st s t n "Array"
  | Get (s,t) -> print_st s t n "Get"
  | Put (s,t,u)->print_stu s t u n "Put"
  )

and print_id_type (id,ty) = (
                             print_string id;
                             print_string ":" ;
                             Type.print_type ty ;
                            )

and print_t t n tag = (print_space n;
                       print_string (tag^"\n");
                       print t (n+1))

and print_st s t n tag = (print_space n;
                          print_string (tag^"\n");
                          print s (n+1);
                          print_string "\n";
                          print t (n+1))

and print_stu s t u n tag = (print_space n;
                             print_string (tag^"\n");
                             print s (n+1);
                             print_string "\n";
                             print t (n+1);
                             print_string "\n";
                             print u (n+1))

