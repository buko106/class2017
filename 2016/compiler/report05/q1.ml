let x = read_int () in
let y = store_x(x) ; (if x <= 0 then f 1 else 2) in
let z = store_y(y) ; let x = restore_x in (if x <= 3 then x-4 else g 5) in
let x = restore_x in
let y = restore_y in
x - y - z
