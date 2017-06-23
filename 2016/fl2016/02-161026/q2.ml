type 'a tree =
  | Leaf
  | Node of 'a * 'a tree * 'a tree

let a =
  Node ( 1 , Node ( 2 , Node ( 3 , Leaf , Leaf ), Node ( 4 , Leaf , Leaf ) ) , Node ( 5 , Node ( 6 , Node ( 7 , Leaf , Leaf ) , Node ( 8 , Leaf , Leaf ) ) , Node ( 9 , Leaf , Leaf ) ) )
          
let rec preorder t =
  match t with
  |Leaf -> []
  |Node (x,l,r) -> (preorder l)@[x]@(preorder r)

let rec inorder t =
  match t with
  |Leaf -> []
  |Node (x,l,r) -> [x]@(inorder l)@(inorder r)

let rec postorder t =
  match t with
  |Leaf -> []
  |Node (x,l,r) -> (postorder l)@(postorder r)@[x]

let levelorder t =
  let rec level_rec n =
    let rec level t n =
      match (t,n) with
      |(Leaf,_) -> []
      |(Node (x,l,r),0) -> [x]
      |(Node (x,l,r),n) -> (level l (n-1))@(level r (n-1))
    in
  match level t n with
  |[] -> []
  |xs -> xs@(level_rec (n+1))
  in
  level_rec 0
