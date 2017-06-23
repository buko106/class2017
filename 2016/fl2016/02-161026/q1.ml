type nat = Z | S of nat

let rec add x y =
  match y with
  | Z -> x
  | S w -> add (S x) w

let rec sub x y =
  match (x,y) with
  |(Z,_) -> Z
  |(x,Z) -> x
  |(S v,S w) -> sub v w

let rec mul x y =
  match y with
  |Z -> Z
  |S w -> add (mul x w) x

let rec pow x y = (* x^y = x*x^{y-1}*)
  match y with
  |Z -> S Z
  |S w -> mul x (pow x w)

let rec i2n x =
  match x with
  |0 -> Z
  |x -> S (i2n (x-1))

let rec n2i x =
  match x with
  |Z -> 0
  |S v -> 1 + n2i v
