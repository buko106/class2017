SOURCE=absyn.ml parser.mli parser.ml lexer.ml absyn2.ml tcheck.ml interpret.ml main.ml

parser.mli parser.ml:
	ocamlyacc parser.mly
lexer.ml:
	ocamllex lexer.mll

tigerint: $(SOURCE)
	ocamlc -o tigerint $(SOURCE)

top:  $(SOURCE)
	ocamlmktop -o tigerint_top $(SOURCE)

clean: 
	rm *.cmi *.cmx *.o *.cmo *.exe parser.ml lexer.ml parser.mli lexer.mli
