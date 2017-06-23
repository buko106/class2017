%{
open Absyn
%}

%token EOF COMMA  COLON  SEMICOLON  LPAREN  RPAREN 
   TINT TSTRING 
   ASSIGN ARRAY  IF  THEN  ELSE  LET IN  END
   BREAK  NIL FUNCTION  VAR 

%token <Absyn.pos> PLUS MINUS TIMES DIVIDE EQ NEQ LT LE
%token <string> STRING
%token <string*Absyn.pos> ID 
%token <int> INT

%nonassoc THEN
%nonassoc ELSE
%nonassoc ASSIGN
%left EQ NEQ LT LE 
%left PLUS MINUS 
%left TIMES DIVIDE
%left UMINUS
%start program
%type <Absyn.exp> exp program 
%type <exp list> expseq
%type <var> lvalue

%%

program	: exp 
 {$1}

exp: NIL
    {NilExp}
  | lvalue
     {VarExp($1)}
  | LPAREN expseq RPAREN
     {SeqExp($2)}
  | INT
     {IntExp($1)}
  | STRING
     {StringExp($1)}
  | MINUS exp %prec UMINUS
     {OpExp(IntExp(0), (MinusOp,$1), $2)}
  | ID LPAREN expseq_comma RPAREN
     {CallExp($1, $3)}
  | exp plusminus exp %prec PLUS
     {OpExp($1, $2, $3)}
  | exp multdiv exp %prec TIMES
     {OpExp($1, $2, $3)}
  | exp relop exp %prec EQ
     {OpExp($1, $2, $3)}
  | lvalue ASSIGN exp
     {AssignExp($1, $3)}
  | IF exp THEN exp ELSE exp 
     {IfExp($2, $4, Some($6))}
  | IF exp THEN exp 
     {IfExp($2, $4, None)}
  | LET dec IN expseq END
     {LetExp($2, SeqExp($4))}

dec : vardec {$1}
  | fundec {$1}

vardec :
   VAR ID ASSIGN exp
    {VarDec($2, ref true, None, $4)}
 | VAR ID COLON ty ASSIGN exp
    {VarDec($2, ref true, Some($4), $6)}

ty : TINT {IntTy}
  | TSTRING {StringTy}

fundec : 
   FUNCTION ID LPAREN tyfields RPAREN EQ exp
    {FunctionDec($2,$4,None, $7)}
 | FUNCTION ID LPAREN tyfields RPAREN COLON ty EQ exp
    {FunctionDec($2,$4,Some($7), $9)}

tyfields : {[]}
 | ID COLON ty 
    {[($1, ref true, $3)]}
 | ID COLON ty COMMA tyfields
    {($1, ref true, $3)::$5}

plusminus : PLUS {(PlusOp,$1)}
  | MINUS {(MinusOp,$1)}

multdiv : TIMES {(TimesOp,$1)}
  | DIVIDE {(DivideOp,$1)}

relop :
    EQ {(EqOp,$1)}
  | NEQ {(NeqOp,$1)}
  | LT {(LtOp,$1)}
  | LE {(LeOp,$1)}

expseq: 
     {[]}
  | exp 
     {[($1)]}
  | exp SEMICOLON expseq
     {($1)::$3}
    
expseq_comma: 
     {[]}
  | exp 
     {[$1]}
  | exp COMMA expseq_comma
     {$1::$3}
    
lvalue: ID
     {$1}
