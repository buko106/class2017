This directory contains source programs for a type checker (with a parser) for mini-Tiger.

main.ml:      main file that defines top-level functions.
tcheck.ml:  source code for type checker
absyn2.ml:    definitions of AST after type checking
lexer.mll:    input for Ocamllex
parser.mly:   input for Ocamlyacc
absyn.ml:     definitions of data structures for AST (abstract syntax trees)
parsetest.ml: defines a function to test parsing
examples:     a directory containing examples of mini-Tiger programs

How to build:
------------
 run "make top" in the top directory 

 Check that a binary file "tchecker" has been created.


How to use
----------
 Run "tchecker". It will just look like the ordinary OCaml top-level interpreter, 
 but the type checker for mini-Tiger is preloaded.

 -----------------------
 $ ./tchecker
      Objective Caml version 3.11.2
 # 
 -----------------------

 To invoke the type checker, invoke the following function.
  Main.main <filename>

  -----------------------
# Main.main "examples/test.tig";;
- : Absyn2.exp * Absyn2.ty =
(Absyn2.LetExp
  (Absyn2.VarDec ("x@1_8", {contents = true}, Absyn.IntTy, Absyn2.IntExp 1),
  Absyn2.SeqExp
   [Absyn2.LetExp
     (Absyn2.VarDec
       ("y@2_9", {contents = true}, Absyn.StringTy, Absyn2.StringExp "abc"),
     Absyn2.SeqExp
      [Absyn2.CallExp ("print", [Absyn2.VarExp ("y@2_9", Absyn.StringTy)]);
       Absyn2.OpExp (Absyn2.VarExp ("x@1_8", Absyn.IntTy),
        (Absyn.PlusOp, Absyn.IntTy), Absyn2.IntExp 1)])]),
 Absyn.IntTy)
   ------------------------------
 The result will be shown like above.

 

 
 
 
 
