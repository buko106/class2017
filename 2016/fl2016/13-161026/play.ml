open Array 
open Color 
open Command 
open Eval

type board = color array array 

let init_board () = 
  let board = Array.make_matrix 10 10 none in 
    for i=0 to 9 do 
      board.(i).(0) <- sentinel ;
      board.(i).(9) <- sentinel ;
      board.(0).(i) <- sentinel ;
      board.(9).(i) <- sentinel ;
    done;
    board.(4).(4) <- white;
    board.(5).(5) <- white;
    board.(4).(5) <- black;
    board.(5).(4) <- black;
    board 

let dirs = [ (-1,-1); (0,-1); (1,-1); (-1,0); (1,0); (-1,1); (0,1); (1,1) ]

let flippable_indices_line board color (di,dj) (i,j) =
  let ocolor = opposite_color color in
  let rec f (di,dj) (i,j) r =
    if board.(i).(j) = ocolor then 
      g (di,dj) (i+di,j+dj) ( (i,j) :: r )
    else 
      [] 
  and    g (di,dj) (i,j) r =
    if board.(i).(j) = ocolor then 
      g (di,dj) (i+di,j+dj) ( (i,j) :: r )
    else if board.(i).(j) = color then 
      r
    else 
      [] in 
    f (di,dj) (i,j) []

let flippable_indices board color (i,j) =
  let bs = List.map (fun (di,dj) -> flippable_indices_line board color (di,dj) (i+di,j+dj)) dirs in
    List.concat bs
    
(* let is_effective board color (i,j) = *)
(*   match flippable_indices board color (i,j) with  *)
(*       [] -> false *)
(*     | _  -> true  *)

(* let is_valid_move board color (i,j) = *)
(*   (board.(i).(j) = none) && is_effective board color (i,j)  *)


let doMove board com color =
  match com with 
      GiveUp  -> board
    | Pass    -> board
    | Mv (i,j) -> 
	let ms = flippable_indices board color (i,j) in 
	let _  = List.map (fun (ii,jj) -> board.(ii).(jj) <- color) ms in 
	let _  = board.(i).(j) <- color in 
	  board 
    | _ -> board 

(* let mix xs ys = *)
(*   List.concat (List.map (fun x -> List.map (fun y -> (x,y)) ys) xs) *)
	     

(* let valid_moves board color =  *)
(*   let ls = [1;2;3;4;5;6;7;8] in  *)
(*   List.filter (is_valid_move board color) *)
(*     (mix ls ls) *)

type othello_board = int64 * int64 (* player * opponent *)

let board_to_othello_board board color =
  let player   = ref 0x0L in
  let opponent = ref 0x0L in
  let ocolor   =  opposite_color color in
  for i=1 to 8 do
    for j=1 to 8 do
      player   := Int64.shift_left !player   1 ;
      opponent := Int64.shift_left !opponent 1 ;
      if board.(i).(j) = color then
        player := Int64.logor !player 0x1L
      else if board.(i).(j) = ocolor then
        opponent := Int64.logor !opponent 0x1L
      else ();
    done
  done;
  (* Printf.printf "player = %016Lx , opponent = %016Lx\n" !player !opponent ; *)
  ( !player , !opponent )


let list_of_moves moves =
  let moves = ref moves in
  let ms = ref [] in
  for i=1 to 8 do
    for j=1 to 8 do
      (if 0x1L = Int64.logand 0x1L !moves then
         ms := (9-i,9-j) :: !ms
       else
         ();
       moves := Int64.shift_right_logical !moves 1)
    done
  done; !ms

let play board color = 
  let ob = board_to_othello_board board color in
  let ( player , opponent ) = ob in
  let ms = valid_moves ob in Printf.printf "valid_move = %016Lx\n" ms ;
    if ms = 0x0L then 
      Pass 
    else
      (* let _  = Hashtbl.clear !table in *)
      (* let _  = hash_hit := 0 in *)
      (* let _  = hash_miss:= 0 in *)
      let depth =  let c = count_moves (Int64.logor player opponent) 0 in
                   let _ = Printf.printf "count = %d\n" c in
                   match c with
                   | c when c >= 52 -> 12
                   | c when c >= 40 ->  8
                   | c              ->  6
      in
      let mv =
        (let best_move = ref 0x0L in
         let best_value= ref (-max_value-2)in
         for i=0 to 63 do
           let pos = Int64.shift_left 0x1L i in
           if 0x0L <> Int64.logand pos ms then
             let value = - (negamax ( opponent , Int64.logor player pos)
                                    depth
                                    (-max_value-1) (max_value+1)) in
             if !best_value < value then
               ( best_move := pos ; best_value := value)
             else ()
           else ()
         done;
         Printf.printf "best_value = %d\n" !best_value;
         !best_move
        ) in
      (* let _ = Printf.printf "hit = %10d , miss = %10d , %02d%%\n" !hash_hit !hash_miss (int_of_float (100.0 *. (float_of_int !hash_hit) /. (float_of_int (!hash_miss + !hash_hit))))in *)
      let mlist = list_of_moves mv in
      let (i,j) = List.hd mlist in 
	Mv (i,j) 


let print_board board = 
  print_endline " |A B C D E F G H ";
  print_endline "-+----------------";
  for j=1 to 8 do 
    print_int j; print_string "|";
    for i=1 to 8 do 
      print_color (board.(i).(j)); print_string " " 
    done;
    print_endline ""
  done;
  print_endline "  (X: Black,  O: White)"



let count board color = 
  let s = ref 0 in 
    for i=1 to 8 do 
      for j=1 to 8 do
        if board.(i).(j) = color then s := !s + 1 
      done
    done;
    !s

let report_result board = 
  let _ = print_endline "========== Final Result ==========" in 
  let bc = count board black in 
  let wc = count board white in 
    if bc > wc then 
      print_endline "*Black wins!*" 
    else if bc < wc then 
      print_endline "*White wins!*" 
    else
      print_endline "*Even*";
    print_string "Black: "; print_endline (string_of_int bc);
    print_string "White: "; print_endline (string_of_int wc);
    print_board board 

