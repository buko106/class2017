let test filename =
  let _ = Lexer.reset_pos() in
  let fp = open_in filename in
  let lexbuf = Lexing.from_channel fp in
  let p = Parser.program Lexer.token lexbuf in
   (close_in fp; p);;


