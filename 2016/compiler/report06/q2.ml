let rec ack x y =
  if x <= 0 then y + 1
  else if y <= 0 then ack (x -1) 1
  else ack (x -1) (ack x (y-1))
in print_int (ack 3 10);;

let rec ack' x y k =
  if x <= 0 then k (y + 1)
  else if y <= 0 then ack' (x -1) 1 k
  else ack' x (y-1) (fun z -> ack' (x-1) z k)
in ack' 3 10 (fun r -> print_int r)

