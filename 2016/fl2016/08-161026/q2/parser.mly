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
%token FUN ARROW REC
%token SHARP
%token QUIT

%nonassoc IN
%nonassoc THEN ELSE
%nonassoc ARROW
%left LOR
%left LAND
%left PLUS MINUS
%left TIMES DIV

%start toplevel 
%type <Syntax.command> toplevel
%% 

toplevel:
  | expr SEMISEMI { CExp $1 }
  | toplevel_dec_chain SEMISEMI { CDecl $1 }
  | LET REC rec_dec SEMISEMI{ CRecDecl $3 }
  | SEMISEMI { CNil }
  | SHARP QUIT SEMISEMI { CQuit }
;

toplevel_dec_chain:
  | dec { $1::[] }
  | dec toplevel_dec_chain { $1::$2 }
;

arg:
  | EQ expr     { $2 }
  | var arg     { EFun($1,$2) }
;

dec:
  | LET var arg  { ($2,$3)::[] }
  | LET var arg dec_and { ($2,$3)::$4}
;

dec_and:
  | AND var arg  { ($2,$3)::[] }
  | AND var arg dec_and { ($2,$3)::$4 }
;

rec_dec:
  | var var arg { ($1,$2,$3)::[] }
  | var var arg AND rec_dec { ($1,$2,$3)::$5 }
;

expr:
  | dec IN expr     { ELet($1,$3) }
  | LET REC rec_dec IN expr { ELetRec($3,$5) }
  | IF expr THEN expr ELSE expr { EIf($2,$4,$6) }
  | FUN fun_expr          { $2 }
  | arith_expr EQ arith_expr    { EEq($1,$3) }
  | arith_expr LT arith_expr    { ELt($1,$3) }
  | arith_expr                  { $1 } 
  | bool_expr                   { $1 }
;

fun_expr:
  | var ARROW expr  { EFun ($1,$3) }
  | var fun_expr    { EFun ($1,$2) }
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
  | factor_expr TIMES app_expr { EMul($1,$3) }
  | factor_expr DIV app_expr   { EDiv($1,$3) }
  | app_expr                   { $1 }
;

app_expr:
  | app_expr atomic_expr  { EApp($1,$2) }
  | atomic_expr           { $1 }

atomic_expr:
  | INT            { EConstInt($1) }
  | BOOL           { EConstBool($1) }
  | ID             { EVar($1) }
  | LPAR expr RPAR { $2 }
;
 
var:
  | ID { $1 }
;
