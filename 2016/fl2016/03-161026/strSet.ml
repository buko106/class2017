(* The type of ordered string sets *)
type t = string list

let empty = []

let rec add elem set =
  match set with
  | [] -> [elem]
  | hd :: tl ->
    if String.compare elem hd > 0 then 
      hd :: add elem tl
    else 
      elem :: set

let rec remove elem = function
  | [] -> []
  | hd :: tl ->
      let c = String.compare elem hd in
      if      c < 0 then hd :: tl 
      else if c = 0 then tl 
      else               hd :: (remove elem tl) 

let rec count_sub elem n = function
  | [] -> n
  | hd::tl ->
      let c = String.compare elem hd in
      if      c < 0 then n
      else if c = 0 then count_sub elem (n + 1) tl
      else               count_sub elem n tl

let count elem set = count_sub elem 0 set

(* converts an ordered set of strings into an ordered list of strings *)
let to_ordered_list set = set
