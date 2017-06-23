(* レジスタはすべてcaller saveとする *)
let ack x y =
  if x=0 then
    y+1
  else if y=0 then
    ack (x-1) 1
  else
    ack (x-1) (ack x (y-1))

(* レジスタR0~R1があるとする、関数の引数はR0から順に、返り値はR0に入れることとする *)

(* 良い割当(退避はxのみで、できるだけ少ない回数) *)
let ack R0 R1 =
  if R0=0 then
    R0=R1+1 (* ; return *)
  else if R1=0 then
    let R0=R0-1 in
    (*call*) ack R0 R1 (* ; return *)
  else
    store_x(R0) ;
    let R1=R1-1 in 
    (*call*) ack R0 R1 ;
    let R1=R0 in
    let R0=restore_x in
    let R0=R0-1 in
    (*call*) ack R0 R1 (* ; reutrn *)

(* 悪い割当(生存解析をせずにすべてストアする、同じ変数は同じレジスタにリストアする) *)
let ack R0 R1 =
  if R0=0 then
    store_x(R0) ;
    R0=R1+1 (* ; return *)
  else if R1=0 then
    store_x(R0) ;
    let R0=R0-1 in
    store_y(R1) ;
    (*call*) ack R0 R1 (* ; return *)
  else
    store_y(R1) ;
    let R1=R1-1 in
    store_x(R0) ;
    (*call*) ack R0 R1 ;
    let R1=R0 in
    let R0=restore_x in
    let R0=R0-1 in
    (*call*) ack R0 R1 (* ; return *)
    
