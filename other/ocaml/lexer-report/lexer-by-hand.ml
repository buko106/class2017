(* 文字列を以下のトークン列に分解して表示するプログラム
   EQ:  =    LEQ: <=   LT: <   PLUS: +  IF: if THEN: then  
   INT: 0 |([1-9][0-9]* )   ID: [a-z]([a-z]|[0-9])*
*)
(* トークンの定義 *)
type token = INVALID | EQ | LEQ | LT | PLUS | IF | THEN | INT | ID

(* 入力文字列を格納しておく場所 *)
let input_buffer: string ref = ref ""

(* 現在読んでいるlexeme(語彙素）の先頭位置 *)
let pos_start = ref 0

(* これから読む文字の位置 *)
let pos_current = ref 0

(* 現在読んでいるlexeme中で最後に認識されたトークン *)
let last_token = ref INVALID

(* 現在読んでいるlexeme中で最後に認識されたトークンの次の文字の位置 *)
let last_pos = ref 0

(* エラー出力 *)
let report_error pos =
  print_string ("invalid token at position "^(string_of_int pos)^"\n")

(* 最後に認識されたトークンに相当する文字列（lexeme） *)
let get_lexeme() =
  let len = !last_pos - !pos_start in String.sub !input_buffer !pos_start len

(* トークンを表示 *)
let output_token token =
  match token with
   EQ -> print_string "EQ "
 | LEQ -> print_string "LEQ "
 | LT -> print_string "LT "
 | PLUS -> print_string "PLUS "
 | IF -> print_string "IF "
 | THEN -> print_string "THEN "
 | INT -> (print_string ("INT("^(get_lexeme())^") "))
 | ID -> print_string ("ID("^(get_lexeme())^") ")
 | INVALID -> assert false

(* 一文字読みこむ *)
let readc() =
  let c = !input_buffer.[!pos_current] in (pos_current:= !pos_current+1; c)
(* マッチしたトークンとその場所を保存 *)
let save token = (last_token := token; last_pos := !pos_current)

(* メイン：文字列inputを受け取り、トークン列に分解して表示 *)
let rec main (input: string) =
   input_buffer := (input^"\000"); (* inputに文字列の最後を表す"\000"を追加 *)
   pos_start := 0; pos_current := 0; last_token := INVALID;
   q0()

and q0 () = (* 初期状態 *)
  match readc() with
   ' ' -> (pos_start := !pos_start+1;
           q0())
  | '=' -> (save EQ; next())
  | '<' -> (save LT; q_lt())
  | '+' -> (save PLUS; next())
  | 'i' -> (save ID; q_i())
  | 't' -> (save ID; q_t())
  | '0' -> (save INT; next())
  | c -> if '1'<=c && c<='9' then (save INT; q_num())
         else if 'a'<= c && c<='z' then (save ID; q_sym())
         else if c='\000' then () (* 文字列の最後なら終了 *)
         else report_error(!pos_current)

and q_lt() =
  match readc() with
    '=' -> (save LEQ; next())
  | _ -> next()

and q_num() = 
  let c= readc() in
    if '0'<=c && c<='9' then (save INT; q_num()) else next()

and q_i() =
  match readc() with
    'f' -> (save IF; q_sym())
  | c -> if ('a'<= c && c<='z')||('0'<=c && c<='9') then (save ID; q_sym())
         else next()

and q_t() = 
  match readc() with
    'h' -> (save ID; q_th())
  | c -> if ('a'<= c && c<='z')||('0'<=c && c<='9') then (save ID; q_sym())
         else next()

and q_th() = 
  match readc() with
    'e' -> (save ID; q_the())
  | c -> if ('a'<= c && c<='z')||('0'<=c && c<='9') then (save ID; q_sym())
         else next()

and q_the() = 
  match readc() with
    'n' -> (save THEN; q_sym())
  | c -> if ('a'<= c && c<='z')||('0'<=c && c<='9') then (save ID; q_sym())
         else next()

and q_sym() =
  let c = readc() in
      if ('a'<= c && c<='z')||('0'<=c && c<='9') then (save ID; q_sym())
      else next()

and next() = 
     if !last_token=INVALID then (* エラー *)
        report_error(!pos_current)
     else (* トークンを表示して次のトークンの処理へ *)
       (output_token !last_token; pos_start := !last_pos;
        pos_current := !pos_start; last_token := INVALID;
        q0())
