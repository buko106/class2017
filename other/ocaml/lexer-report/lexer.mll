{
(* A sample input for ocamllex.
   Usage:
     1. Run "ocamllex lexer.mll"
     2. Invoke an ocaml interpreter; and run:
      #use "lexer.ml";;
      main <an input file name for the lexical analyzer>
 *)
(* This part will be attached to the beginning of the generated code *)
let line_no = ref 1  (* the current line number, used for error reporting *)
let end_of_previousline = ref 0
(* data type declaration for tokens *)
type token = EQ | LEQ | LT | GEQ | GT | PLUS | MINUS | TIMES | LPAREN | RPAREN 
           | IF | THEN | ELSE | INT of int | ID of string | EOF
}

(* abbreviations *)
let space = [' ' '\t' '\r']
let newline = ['\n']
let digit = ['0'-'9']
let digitnz = ['1'-'9']
let lower = ['a'-'z']

(* The main part, defining tokens and the corresponding actions *)
rule token = parse
| space+    { token lexbuf }
| newline
    { end_of_previousline := (Lexing.lexeme_end lexbuf);
      line_no := !line_no+1;
      token lexbuf}
| "+" {PLUS}
| "-" {MINUS}
| "*" {TIMES}
| "(" {LPAREN}
| ")" {RPAREN}
| "=" {EQ}
| "<=" {LEQ}
| "<" {LT}
| ">=" {GEQ}
| ">" {GT}
| "0" {INT(0)}
| "if" {IF}
| "then" {THEN}
| "else" {ELSE}
| digitnz digit* 
   {let s = Lexing.lexeme lexbuf in INT(int_of_string s)}
| lower (digit|lower)*
    { let s = Lexing.lexeme lexbuf in ID(s)}
| eof { EOF }
| "(*" { comment lexbuf; token lexbuf }
| _
    { Format.eprintf "unknown token %s in line %d, column %d-%d @."
	(Lexing.lexeme lexbuf)
        (!line_no)
	((Lexing.lexeme_start lexbuf)- (!end_of_previousline))
	((Lexing.lexeme_end lexbuf)-(!end_of_previousline));
      failwith "lex error" }

(* For nested comments. *)
and comment = parse
| "*)"
    { () }
| "(*"
    { comment lexbuf; comment lexbuf }
| eof
    {  print_string "Lex error: unterminated comment\n";
       failwith "unterminated comment" }
| _
    { comment lexbuf }

{
(* This part is added to the end of the generated code *)
(* The following is a piece of code for testing the generated lexical analyzer. *)
let rec readloop lexbuf =
  let t = token lexbuf in
    if t=EOF then []
    else t::(readloop lexbuf)

(* main takes a filename, performs a lexical analysis, and
   returns the result as a list of tokens.
 *)
let main filename =
  let lexbuf = Lexing.from_channel (open_in filename) in
     readloop lexbuf
}