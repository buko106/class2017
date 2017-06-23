let rec id x =
  let rec id x =
    let rec id x =
      let y = x + x in
      let z = x + x in
      y + (x + x) + z
    in id x
  in
  id x
in print_int(id 2)
