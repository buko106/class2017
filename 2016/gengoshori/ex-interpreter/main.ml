
let parseFile filename =
  let fp = open_in filename in
  let lexbuf = Lexing.from_channel fp in
  let p = Parser.program Lexer.token lexbuf in
   (close_in fp; p);;

let interpret filename =
  let exp = parseFile(filename) in
  let (typed_exp,_) = Tcheck.main exp in
    Interpret.main typed_exp ;;

let tcheck filename =
  let exp = parseFile(filename) in
  let (typed_exp,_) = Tcheck.main exp in
    typed_exp;;

if !Sys.interactive then
  ()
else
  interpret(Sys.argv.(1))

