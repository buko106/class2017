open Color


let max_value = max_int-100
(* let size_of_hash = 2000000 *)
(* let table = ref (Hashtbl.create  size_of_hash) *)
(* let hash_miss = ref 0 *)
(* let hash_hit  = ref 0 *)

let rec count_moves (ms:int64) (ret:int) : int =
  if 0x0L = ms then
    ret
  else
    count_moves (Int64.shift_right_logical ms 1) (ret+(if Int64.logand ms 0x1L = 0x1L then 1 else 0))


let valid_moves (player,opponent)=
  let valid_moves_sub mask dir =
    let flip = ref (Int64.logand mask (Int64.logor 
                                        (Int64.shift_left player dir)
                                        (Int64.shift_right_logical player dir))) in
    (flip := Int64.logor 
               !flip (Int64.logand mask 
                                   (Int64.logor
                                      (Int64.shift_left !flip dir)
                                      (Int64.shift_right_logical !flip dir)));
     flip := Int64.logor 
               !flip (Int64.logand mask 
                                   (Int64.logor
                                      (Int64.shift_left !flip dir)
                                      (Int64.shift_right_logical !flip dir)));
     flip := Int64.logor 
               !flip (Int64.logand mask 
                                   (Int64.logor
                                      (Int64.shift_left !flip dir)
                                      (Int64.shift_right_logical !flip dir)));
     flip := Int64.logor 
               !flip (Int64.logand mask 
                                   (Int64.logor
                                      (Int64.shift_left !flip dir)
                                      (Int64.shift_right_logical !flip dir)));
     flip := Int64.logor 
               !flip (Int64.logand mask 
                                   (Int64.logor
                                      (Int64.shift_left !flip dir)
                                      (Int64.shift_right_logical !flip dir)));
     (Int64.logor
        (Int64.shift_left !flip dir)
        (Int64.shift_right_logical !flip dir))
    )
  in 
  let moves = ref 0x0L in
  (moves := Int64.logor !moves (valid_moves_sub
                                  (Int64.logand opponent 0x7E7E7E7E7E7E7E7EL)
                                  1);
   moves := Int64.logor !moves (valid_moves_sub
                                  (Int64.logand opponent 0x00FFFFFFFFFFFF00L)
                                  8);
   moves := Int64.logor !moves (valid_moves_sub
                                  (Int64.logand opponent 0x007E7E7E7E7E7E00L)
                                  7);
   Int64.logand (Int64.lognot (Int64.logor player opponent))
           (Int64.logor !moves (valid_moves_sub
                                  (Int64.logand opponent 0x007E7E7E7E7E7E00L)
                                  9)))

let pos_val = [|  99 ; -10 ;  10 ;   4 ;
                       -10 ;   2 ;   2 ;
                               5 ;   4 ;
                                     4 |]
let num_to_pos = [| 0 ; 1 ; 2 ; 3 ; 3 ; 2 ; 1 ; 0 ;
                    1 ; 4 ; 5 ; 6 ; 6 ; 5 ; 4 ; 1 ;
                    2 ; 5 ; 7 ; 8 ; 8 ; 7 ; 5 ; 2 ;
                    3 ; 6 ; 8 ; 9 ; 9 ; 8 ; 6 ; 3 ;
                    3 ; 6 ; 8 ; 9 ; 9 ; 8 ; 6 ; 3 ;
                    2 ; 5 ; 7 ; 8 ; 8 ; 7 ; 5 ; 2 ;
                    1 ; 4 ; 5 ; 6 ; 6 ; 5 ; 4 ; 1 ;
                    0 ; 1 ; 2 ; 3 ; 3 ; 2 ; 1 ; 0 |]
let stone_val = Array.init 64 (fun i -> pos_val.(num_to_pos.(i)))

let sum_of_ob (player,opponent) =
  let rec sum i ret =
    if i > 63 then
      ret
    else
      let pos = Int64.shift_left 0x1L i in
      sum (i+1) (if 0x0L <> Int64.logand pos player then
                   stone_val.(i) + ret
                 else if 0x0L <> Int64.logand pos opponent then
                   -stone_val.(i) + ret
                 else 
                   ret)
  in sum 0 0



let eval ob = 
  let value = ref (10 * (count_moves (valid_moves ob) 0)) in
  let (player , opponent) = ob in
  if Int64.logor player opponent = 0xFFFFFFFFFFFFFFFFL then
    let pval = count_moves player 0 in
    let oval = count_moves opponent 0 in
    if      pval < oval then (-max_value)
    else if pval > oval then max_value
    else                     0
  else
    5 * ((count_moves (valid_moves (player,opponent)) 0)-(count_moves (valid_moves (opponent,player)) 0))
    + sum_of_ob ob                                         

let get_rev ( player , opponent ) m = (* ただしmvは合法手 *)
  let get_rev_sub_right guard dir =        (* dir>0 *)
    let rev =ref 0x0L in
    let mask=ref (Int64.logand (Int64.shift_right_logical m dir) guard) in
    while !mask <> 0x0L && (Int64.logand !mask opponent) <> 0x0L do
      (rev := Int64.logor !rev !mask;
       mask:= (Int64.logand (Int64.shift_right_logical !mask dir) guard))
    done;
    if Int64.logand !mask player = 0x0L then
      0x0L
    else
      !rev
  in
  let get_rev_sub_left guard dir =
    let rev =ref 0x0L in
    let mask=ref (Int64.logand (Int64.shift_left m dir) guard) in
    while !mask <> 0x0L && (Int64.logand !mask opponent) <> 0x0L do
      (rev := Int64.logor !rev !mask;
       mask:= (Int64.logand (Int64.shift_left !mask dir) guard))
    done;
    if Int64.logand !mask player = 0x0L then
      0x0L
    else
      !rev
  in
  (Int64.logor
     (Int64.logor
        (Int64.logor (get_rev_sub_right 0x7F7F7F7F7F7F7F7FL 1)
                     (get_rev_sub_right 0x00FFFFFFFFFFFFFFL 8))
        (Int64.logor (get_rev_sub_right 0x00FEFEFEFEFEFEFEL 7)
                     (get_rev_sub_right 0x007F7F7F7F7F7F7FL 9)))
     (Int64.logor
        (Int64.logor (get_rev_sub_left  0xFEFEFEFEFEFEFEFEL 1)
                     (get_rev_sub_left  0xFFFFFFFFFFFFFF00L 8))
        (Int64.logor (get_rev_sub_left  0x7F7F7F7F7F7F7F00L 7)
                     (get_rev_sub_left  0xFEFEFEFEFEFEFE00L 9)))
  )

let rec negamax (player,opponent) (depth:int) alpha beta : int =
  (* let _ = Printf.printf "depth = %d\n" depth in *)
  if depth = 0 then
    eval (player,opponent)
    (* if Hashtbl.mem !table (player,opponent) then *)
    (*   (hash_hit := !hash_hit+1;Hashtbl.find !table (player,opponent)) *)
    (* else *)
    (*   (let v = eval (player,opponent) in *)
    (*    Hashtbl.add !table (player,opponent) v ; *)
    (*    hash_miss := !hash_miss+1; *)
    (*    v) *)
  else
    let a = valid_moves (player,opponent) in
    (* let _ = Printf.printf "valid_moves = %016Lx\n" a in *)
    let best = ref (-max_value) in
    if a = 0x0L then
      - (negamax ( opponent , player) (depth-1) (-beta) (-alpha))
    else
      let alpha = ref alpha in
      let rec loop i =
        if i >= 63 then
          !alpha
        else
          (let pos = Int64.shift_left 0x1L i in
           if 0x0L <> Int64.logand pos a then
             let rev = get_rev (player , opponent) pos in
             alpha := max !alpha 
                          (- (negamax (Int64.logxor opponent rev,
                                       Int64.logxor player (Int64.logor pos rev))
                                      (depth-1)
                                      (-beta)
                                      (- (!alpha))))
           else ();
           if !alpha >= beta then !alpha
           else loop (i+1))
      in loop 0
