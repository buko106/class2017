This directory contains source programs for a parser for mini-Tiger.

lexer.mll:    input for Ocamllex
parser.mly:   input for Ocamlyacc
absyn.ml:     definitions of data structures for AST (abstract syntax trees)
parsetest.ml: defines a function to test parsing
examples:     a directory containing examples of mini-Tiger programs

How to build:
------------
 run "make top" in the top directory 

 Check that a binary file "parsetest" has been created.


How to use
----------
 Run "parsetest". It will just look like the ordinary OCaml top-level interpreter, 
 but the parser for mini-Tiger is preloaded.

 -----------------------
 $ ./parsetest
      Objective Caml version 3.11.2
 # 
 -----------------------

 To invoke the parser, invoke the following function.
  Parsetest.test <filename>

  -----------------------
  # Parsetest.test "examples/fib.tig";;

  - : Absyn.exp =
  Absyn.LetExp
   (Absyn.FunctionDec
     (("fib", (2, 12)), [(("n", (2, 17)), {contents = true}, Absyn.IntTy)],
      Some Absyn.IntTy,
      Absyn.IfExp
       (Absyn.OpExp (Absyn.VarExp ("n", (3, 9)), (Absyn.LtOp, (3, 10)),
         Absyn.IntExp 2),
       Absyn.VarExp ("n", (3, 18)),
       Some
        (Absyn.OpExp
          (Absyn.CallExp (("fib", (3, 25)),
            [Absyn.OpExp (Absyn.VarExp ("n", (3, 29)),
              (Absyn.MinusOp, (3, 30)), Absyn.IntExp 1)]),
          (Absyn.PlusOp, (3, 33)),
          Absyn.CallExp (("fib", (3, 34)),
           [Absyn.OpExp (Absyn.VarExp ("n", (3, 38)), (Absyn.MinusOp, (3, 39)),
             Absyn.IntExp 2)]))))),
   Absyn.SeqExp [Absyn.CallExp (("fib", (5, 3)), [Absyn.IntExp 5])])
 ------------------------------
 The parse result will be shown like above.

 

 
 
 
 
