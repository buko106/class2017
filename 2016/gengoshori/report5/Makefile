SOURCE=absyn.ml parser.mli parser.ml lexer.ml parsetest.ml

parser.mli parser.ml:
	ocamlyacc parser.mly
lexer.ml:
	ocamllex lexer.mll

top:  $(SOURCE)
	ocamlmktop -o parsetest $(SOURCE)

clean: 
	rm *.cmi *.cmx *.o *.cmo *.exe parser.ml lexer.ml parser.mli lexer.mli
