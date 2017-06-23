let digit = ['0'-'9']
let space = ' ' | '\t' | '\r' | '\n'
let alpha = ['a'-'z' 'A'-'Z' '_' ]
let ident = alpha (alpha | digit)* 

rule main = parse
| space+       { main lexbuf }
| "+"          { Parser.PLUS }
| "*"          { Parser.TIMES }
| "-"          { Parser.MINUS }
| "/"          { Parser.DIV }
| "="          { Parser.EQ }
| "<"          { Parser.LT }
| "let"        { Parser.LET }
| "and"        { Parser.AND }
| "in"         { Parser.IN }
| "if"         { Parser.IF }
| "then"       { Parser.THEN }
| "else"       { Parser.ELSE }
| "true"       { Parser.BOOL (true) }
| "false"      { Parser.BOOL (false) }
| "&&"         { Parser.LAND }
| "||"         { Parser.LOR }
| "#"          { Parser.SHARP }
| "("          { Parser.LPAR }
| ")"          { Parser.RPAR }
| "fun"        { Parser.FUN }
| "rec"        { Parser.REC }
| "->"         { Parser.ARROW }
| "match"      { Parser.MATCH }
| "with"       { Parser.WITH }
| "|"          { Parser.BAR }
| "["          { Parser.LBRACKET }
| "]"          { Parser.RBRACKET }
| "::"         { Parser.CONS }
| ","          { Parser.COMMA }
| ";"          { Parser.SEMI }
| ":="         { Parser.ASSIGN }
| "!"          { Parser.EXCLAMATION }
| "quit"       { Parser.QUIT }
| "for"        { Parser.FOR }
| "while"      { Parser.WHILE }
| "do"         { Parser.DO }
| "done"       { Parser.DONE }
| "to"         { Parser.TO }
| "_"          { Parser.WILDCARD }
| ";;"         { Parser.SEMISEMI }
| digit+ as n  { Parser.INT (int_of_string n) }
| ident  as id { Parser.ID id }
| _            { failwith ("Unknown Token: " ^ Lexing.lexeme lexbuf)}
