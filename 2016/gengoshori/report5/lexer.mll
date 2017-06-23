{
open Parser
exception LexError of string
let line_no = ref 1
let end_of_previousline = ref 0
let strbuffer = ref ""
let get_pos lexbuf = (!line_no, (Lexing.lexeme_start lexbuf)-(!end_of_previousline))
let reset_pos() = (line_no := 1; end_of_previousline := 0)
}

let space = [' ' '\t' '\r']
let newline = ['\n']
let digit = ['0'-'9']
let lower = ['a'-'z']
let upper = ['A'-'Z']
let char = [' '-'!' '#'-'[' ']'-'z']
rule token = parse
| space+
    { token lexbuf }
| newline
    { end_of_previousline := (Lexing.lexeme_end lexbuf);
      line_no := !line_no+1;
      token lexbuf}
| "/*"
    { comment lexbuf;
      token lexbuf }
| "," {COMMA}
| ":" {COLON}
| ";" {SEMICOLON}
| "(" {LPAREN}
| ")" {RPAREN}
| "+" {PLUS(get_pos lexbuf)}
| "-" {MINUS(get_pos lexbuf)}
| "*" {TIMES(get_pos lexbuf)}
| "/" {DIVIDE(get_pos lexbuf)}
| "=" {EQ(get_pos lexbuf)}
| "<>" {NEQ(get_pos lexbuf)}
| "<" {LT(get_pos lexbuf)}
| "<=" {LE(get_pos lexbuf)}
| ">" {GT(get_pos lexbuf)}
| ">=" {GE(get_pos lexbuf)}
| ":="  {ASSIGN}
| "int" {TINT}
| "string" {TSTRING}
| "if"  {IF}
| "then"  {THEN}
| "else"  {ELSE}
| "let"  {LET}
| "in"  {IN}
| "end"  {END}
| "while" {WHILE}
| "do"  {DO}
| "nil"  {NIL}
| "function"  {FUNCTION}
| "var"  {VAR}

| (lower|upper) (digit|lower|upper|'_')*
    { let s = Lexing.lexeme lexbuf in
         ID(s,get_pos lexbuf)}
| digit digit* 
   {let s = Lexing.lexeme lexbuf in
     INT(int_of_string s)}
| eof
    { EOF }
| '"' {strbuffer := ""; tigerstring lexbuf; STRING(!strbuffer)}
| _
    { Format.eprintf "unknown token %s in line %d, column %d-%d @."
	(Lexing.lexeme lexbuf)
        (!line_no)
	((Lexing.lexeme_start lexbuf)- (!end_of_previousline))
	((Lexing.lexeme_end lexbuf)-(!end_of_previousline));
      failwith "lex error" }
and comment = parse
| "*/"
    { () }
| "/*"
    { comment lexbuf;
      comment lexbuf }
| eof
    {  print_string "Lex error: unterminated comment\n";
       failwith "unterminated comment" }
| _
    { comment lexbuf }
and tigerstring = parse
| '"' { () }
| "\\" { escape lexbuf; tigerstring lexbuf}
| _ {let s = Lexing.lexeme lexbuf in
        (strbuffer := (!strbuffer)^s; tigerstring lexbuf)}
and escape = parse
| 'n' {let _ = Lexing.lexeme lexbuf in
        (strbuffer := (!strbuffer)^"\n")}
| 't' {let _ = Lexing.lexeme lexbuf in
        (strbuffer := (!strbuffer)^"\t")}
| "\\" {let _ = Lexing.lexeme lexbuf in
        (strbuffer := (!strbuffer)^"\\")}
| '"' {let _ = Lexing.lexeme lexbuf in
        (strbuffer := (!strbuffer)^"\"")}
| digit digit digit
      {let s = Lexing.lexeme lexbuf in
       let n = int_of_string s in 
       let s' = String.make 1 (char_of_int n) in
          (strbuffer := (!strbuffer)^s') }
| _ {ignorestr lexbuf}
and ignorestr = parse
| "\\" { ()}
| _ {ignorestr lexbuf}
