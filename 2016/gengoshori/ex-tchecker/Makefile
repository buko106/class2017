SOURCE=absyn.ml parser.mli parser.ml lexer.ml absyn2.ml tcheck.ml main.ml

parser.mli parser.ml:
	ocamlyacc parser.mly
lexer.ml:
	ocamllex lexer.mll

top:  $(SOURCE)
	ocamlmktop -o tchecker $(SOURCE)

clean: 
	rm *.cmi *.cmx *.o *.cmo *.exe parser.ml lexer.ml parser.mli lexer.mli
