let scan_num () = Scanf.scanf " %d " (fun x -> if x<0 || x>9 then raise (Invalid_argument (string_of_int x)) else x)

let to_row    n = n / 9
let to_column n = n mod 9
let to_masu   n = let r = n / 27 in
                  let c = (n mod 9) / 3 in
                  3*r + c

let init2 n m f = Array.init n (fun i -> Array.init m (fun j -> f i j))

let scan_problem () = Array.init 81 (fun _ -> scan_num ())
let print_answer ans =
  print_string "\n";
  for i=0 to 80 do
    Printf.printf (if i mod 9 = 8 then "%d\n" else "%d") ans.(i)
  done

let rec solve board row column masu n = 
  (* let _ = Printf.printf "n = %d\n" n in *)
  if n = 81 then
    print_answer board
  else
    if board.(n) <> 0 then
      let _ = row.(to_row n).(board.(n)) <- true in
      let _ = column.(to_column n).(board.(n)) <- true in
      let _ = masu.(to_masu n).(board.(n)) <- true in
      solve board row column masu (n+1)
    else (* n=0 *)
      for i=1 to 9 do
        if row.(to_row n).(i) = false
           &&column.(to_column n).(i) = false
           &&masu.(to_masu n).(i) = false then
          let _ = board.(n) <- i in
          let _ = row.(to_row n).(i) <- true in
          let _ = column.(to_column n).(i) <- true in
          let _ = masu.(to_masu n).(i) <- true in
          let _ = solve board row column masu (n+1) in
          let _ = board.(n) <- 0 in
          let _ = row.(to_row n).(i) <- false in
          let _ = column.(to_column n).(i) <- false in
          let _ = masu.(to_masu n).(i) <- false in
          ()
        else ()  
      done
        
let main board=
  let row = init2 9 10 (fun _ _ -> false) in
  let column = init2 9 10 (fun _ _ -> false) in
  let masu = init2 9 10 (fun _ _ -> false) in
  solve board row column masu 0

