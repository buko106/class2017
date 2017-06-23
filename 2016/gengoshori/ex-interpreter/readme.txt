This directory contains source programs for a type checker and an interpreter for mini-Tiger.

main.ml:      main file that defines top-level functions.
tchecker.ml:  source code for type checker
interpret.ml  source code for interpreter
absyn2.ml:    definitions of AST after type checking
lexer.mll:    input for Ocamllex
parser.mly:   input for Ocamlyacc
absyn.ml:     definitions of data structures for AST (abstract syntax trees)
examples:     a directory containing examples of mini-Tiger programs

How to build:
------------
 run "make top" in the top directory 

 Check that a binary file "tigerint_top" has been created.


How to use
----------
 Run "tigerint_top". It will just look like the ordinary OCaml top-level interpreter, 
 but the type checker and interpreter for mini-Tiger are preloaded.

 -----------------------
 $ ./tigerint_top
      Objective Caml version 3.11.2
 # 
 -----------------------

 To invoke the type checker, call the following function.
  Main.tcheck <filename>

  -----------------------
# Main.tcheck "examples/test.tig";;
- : Absyn2.exp =
Absyn2.LetExp
 (Absyn2.VarDec ("x@1_8", {contents = true}, Absyn.IntTy, Absyn2.IntExp 1),
 Absyn2.SeqExp
  [Absyn2.LetExp
    (Absyn2.VarDec
      ("y@2_9", {contents = true}, Absyn.StringTy, Absyn2.StringExp "abc\n"),
    Absyn2.SeqExp
     [Absyn2.CallExp ("print", [Absyn2.VarExp ("y@2_9", Absyn.StringTy)]);
      Absyn2.OpExp (Absyn2.VarExp ("x@1_8", Absyn.IntTy),
       (Absyn.PlusOp, Absyn.IntTy), Absyn2.IntExp 1)])])
   ------------------------------
 The result will be shown like above.
 As shown above, a unique name is assigned to each variable, which is of the form
  <original variable name>@<line>_<column>
  <line> and <column> indicate the position in the source program where the variable
  is defined.

 To run the interpreter, call the following function.
  Main.interpret <filename>

 -------------------------
# Main.interpret "examples/test.tig";;
abc
val it = 2
- : unit = ()
 -------------------------


The interpreter is incomplete for function definitions.

-----------------------------------
# Main.interpret "examples/fib.tig";;
Exception: Absyn2.TODO.
-----------------------------------

You need to complete interpret.ml to support function definitions.
 
 
 
