
let parseFile filename =
  let fp = open_in filename in
  let lexbuf = Lexing.from_channel fp in
  let p = Parser.program Lexer.token lexbuf in
   (close_in fp; p);;

let main filename =
  let exp = parseFile(filename) in
    Tcheck.main exp ;;


