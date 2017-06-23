(* if ocaml *) let print_byte x = print_char (char_of_int x) in
let rec write_header _ =
  print_byte 80;                (* P *)
  print_byte (48+3);            (* +6 if binary *)
  print_byte 10;                (* new line *)
  print_int 1024;
  print_byte 32;                (* space *)
  print_int 1024;
  print_byte 32;                (* space *)
  print_int 255;                (* 0~255 *)
  print_byte 10                 (* new line *)
in

let step = let a = Array.create 6 0 in
           (
             a.(0) <- 3 ;
             a.(1) <- 5 ;
             a.(2) <- 8 ;
             a.(3) <- 11;
             a.(4) <- 30;
             a.(5) <- 100;
             a
           )
in             

let rec write_rgb x =
  let rec write fr fg fb =
    let r = int_of_float fr in
    let g = int_of_float fg in
    let b = int_of_float fb in
    print_byte 32;                (* space *)
    print_int r;
    print_byte 32;                (* space *)
    print_int g;
    print_byte 32;                (* space *)
    print_int b
  in
  let fx = float_of_int x in
  if x <= step.(0) then
    write 255.0 0.0 0.0
  else if x <= step.(1) then
    write 255.0 (255.0 *. float_of_int (x-step.(0)) /. float_of_int (step.(1) - step.(0))) 0.0
  else if x <= step.(2) then
    write (255.0 *. float_of_int (step.(2)-x) /. float_of_int (step.(2) - step.(1) )) 255.0 0.0
  else if x <= step.(3) then
    write 0.0 255.0 (255.0 *. float_of_int (x-step.(2)) /. float_of_int (step.(3) - step.(2)))
  else if x <= step.(4) then
    write 0.0 (255.0 *. float_of_int (step.(4)-x) /. float_of_int (step.(4) - step.(3) )) 255.0
  else if x <= step.(5) then
    write (255.0 *. float_of_int (x-step.(4)) /. float_of_int (step.(5) - step.(4))) 0.0 255.0
  else write 0.0 0.0 0.0
in
let rec yloop y =
  if y >= 1024 then () else
    let rec xloop x y =
      if x >= 1024 then () else
        let fx = float_of_int x in
        let fy = float_of_int y in
        let cr = fx /. 512.0 -. 1.5 in
        let ci = fy /. 512.0 -. 1.0 in
        let rec iloop i zr zi cr ci=
          if i >= 256 then write_rgb 256 else
            let nr = zr *. zr -. zi *. zi +. cr in
            let ni = 2.0 *. zr *. zi +. ci in
            if zr *. zr +. zi *. zi > 2.0 *. 2.0 then
              write_rgb i
            else
              iloop (i+1) nr ni cr ci in
        iloop 0 0.0 0.0 cr ci;
        xloop (x+1) y in
    xloop 0 y;
    yloop (y+1)
in
write_header ();
yloop 0
