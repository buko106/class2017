open Syntax
open Eval
       
let rec read_eval_print env =
  print_string "# ";
  flush stdout;
  try
    let cmd = Parser.toplevel Lexer.main (Lexing.from_channel stdin) in
    let (id_v, newenv ) = eval_command env cmd in
    ((* Printf.printf "%s = " id; *)
     (* print_value v; *)
     (* print_newline (); *)
     let rec print_id_v = function
       | [] -> ()
       |(id,v)::tl ->
         (print_id_v tl;
          Printf.printf "%s = " id;
          print_value v;
          print_newline ();) in
     print_id_v id_v;
     read_eval_print newenv)
  with
  |Failure msg ->
    (Printf.printf "Error: Lexing error(%s)" msg;
     print_newline();
     read_eval_print env)
  |Parsing.Parse_error ->
    (Printf.printf "Error: Parsing error";
     print_newline();
     read_eval_print env)
  |Eval.EvalErr msg -> 
    (Printf.printf "Error: EvalErr(\"%s\")" msg;
     print_newline ();
     read_eval_print env)
  |Exit -> ()
  | _ ->
     (Printf.printf "Error: Internal Error";
      print_newline ();
      read_eval_print env)
let initial_env = empty_env
    
let _ = read_eval_print initial_env
