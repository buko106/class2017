%{
  open Syntax
  (* ここに書いたものは，ExampleParser.mliに入らないので注意 *)
%}

%token <int>    INT
%token <bool>   BOOL 
%token <string> ID
%token LET IN AND
%token PLUS TIMES MINUS DIV
%token LAND LOR
%token EQ LT
%token IF THEN ELSE
%token LPAR RPAR 
%token SEMISEMI
%token SHARP
%token QUIT

%nonassoc IN
%nonassoc THEN ELSE
%left LOR
%left LAND

%start toplevel 
%type <Syntax.command> toplevel
%% 

toplevel:
  | expr SEMISEMI { CExp $1 }
  | toplevel_dec_chain SEMISEMI { CDecl $1 }
  | SHARP QUIT SEMISEMI{ CQuit }
;

toplevel_dec_chain:
  | dec { $1::[] }
  | dec toplevel_dec_chain { $1::$2 }
;

dec:
  | LET var EQ expr  { ($2,$4)::[] }
  | LET var EQ expr dec_and { ($2,$4)::$5}
;

dec_and:
  | AND var EQ expr  { ($2,$4)::[] }
  | AND var EQ expr dec_and { ($2,$4)::$5 }
;

expr:
  | dec IN expr     { ELet($1,$3) }
  | IF expr THEN expr ELSE expr { EIf($2,$4,$6) }
  | arith_expr EQ arith_expr    { EEq($1,$3) }
  | arith_expr LT arith_expr    { ELt($1,$3) }
  | arith_expr                  { $1 } 
  | bool_expr                   { $1 }
;


arith_expr:
  | arith_expr PLUS factor_expr  { EAdd($1,$3) }
  | arith_expr MINUS factor_expr { ESub($1,$3) }
  | factor_expr                  { $1 }
;

bool_expr:
  | expr LAND expr { EAnd($1,$3) }
  | expr LOR  expr { EOr($1,$3) }
;

factor_expr:
  | factor_expr TIMES atomic_expr { EMul($1,$3) }
  | factor_expr DIV atomic_expr   { EDiv($1,$3) }
  | atomic_expr                   { $1 }
;

atomic_expr:
  | INT            { EConstInt($1) }
  | BOOL           { EConstBool($1) }
  | ID             { EVar($1) }
  | LPAR expr RPAR { $2 }
;
 
var:
  | ID { $1 }
;
