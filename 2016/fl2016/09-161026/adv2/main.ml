open Syntax
open Infer
open Eval
       
let rec read_eval_print env tyenv=
  print_string "# ";
  flush stdout;
  try
    let cmd = Parser.toplevel Lexer.main (Lexing.from_channel stdin) in
    let (id_v, newenv , newtyenv ) = eval_command env tyenv cmd in
    (let rec print_id_v = function
       | [] -> ()
       |(id,v)::tl ->
         (print_id_v tl;
          Printf.printf "%s = " id;
          print_value v;
          print_newline ();) in
     print_id_v id_v;
     read_eval_print newenv newtyenv)
  with
  |Failure msg ->
    (Printf.printf "Error: Lexing error(%s)" msg;
     print_newline();
     read_eval_print env tyenv)
  |Parsing.Parse_error ->
    (Printf.printf "Error: Parsing error";
     print_newline();
     read_eval_print env tyenv)
  |Eval.EvalErr msg -> 
    (Printf.printf "Error: EvalErr(\"%s\")" msg;
     print_newline ();
     read_eval_print env tyenv)
  |Infer.InferErr msg ->
    (Printf.printf "Error: InferErr(\"%s\")" msg;
     print_newline ();
     read_eval_print env tyenv)
  |Exit -> ()
  | _ ->
     (Printf.printf "Error: Internal Error";
      print_newline ();
      read_eval_print env tyenv)
       
let initial_env = [ ( "ref" , VMakeRef ) ]
let initial_tyenv= let a = new_tyvar () in [ ( "ref" , ([a],TFun(TVar a,TRef (TVar a))) ) ]
let _ = read_eval_print initial_env initial_tyenv
