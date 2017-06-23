open Main
open Syntax
open Eval
open Tcheck
let topenv = ref (emptyenv())

let rec ocaml () = 
  begin
    print_string ">" ;
    print_string (string_of_val (eval (parse (read_line ())) !topenv));
    print_string "\n" ;
    ocaml ()
  end
