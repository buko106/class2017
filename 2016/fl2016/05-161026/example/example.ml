open Syntax

let main () =
  try 
    let lexbuf = Lexing.from_channel stdin in 
    let result = Parser.toplevel Lexer.main lexbuf in
    print_command result; print_newline ()
  with 
    | Parsing.Parse_error -> 
      print_endline "Parse Error!"
      
;;
if !Sys.interactive then 
  ()
else 
  main ()    

    
    
  
  
