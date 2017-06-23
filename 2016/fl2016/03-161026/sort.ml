
open StrSet

let s = ref empty

let _ =
  try
    while true do
      s := add (read_line ()) !s
    done
  with End_of_file ->
    let l = to_ordered_list !s in
    let rec iter = function
      | [] -> ()
      | hd::tl -> print_endline hd; iter tl
    in
    iter l
