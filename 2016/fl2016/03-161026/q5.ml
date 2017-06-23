module type SEMIRING = sig
  type t
  val add : t->t->t
  val mul : t->t->t
  val unit : t
  val zero : t
end

module type MATRIX =
  functor ( SemiRing : SEMIRING ) ->
  sig
    type t 
    val init : int -> int -> (int -> int -> SemiRing.t) -> t
    val of_list : SemiRing.t list list -> t
    val to_list : t -> SemiRing.t list list
    val at : t -> int -> int -> SemiRing.t
    val unit : int -> t
    val zero : int -> int -> t
    val add : t -> t -> t
    val mul : t -> t -> t
    val pow : t -> int -> t
  end

module Matrix:MATRIX = 
  functor ( SemiRing : SEMIRING ) ->
  struct
    type t = int * int * SemiRing.t array array
    exception Size_unmatch
    let init row column f = (row,column,
                             Array.init row (fun r -> Array.init column (f r)))
    let size_check a =
      if List.length a = 0 then
        (0,0)
      else
        let c = List.length (List.hd a) in
        if c = 0 then
          (0,0)
        else
          let rec size_check_sub a r =
            match a with
            | [] -> (r,c)
            |hd::tl ->
              if List.length hd = c then
                size_check_sub tl (r+1)
              else
                (0,0)
          in size_check_sub a 0
                           
    let of_list a = 
      match size_check a with
      |(0,0) -> raise Size_unmatch
      |(r,c) -> (r,c,Array.of_list (List.map (fun l -> Array.of_list l) a))
    let to_list (_,_,a) = Array.to_list (Array.map (fun v -> Array.to_list v) a)
    let at (r,c,a) i j =
      if i<0 || i>(r-1) || j<0 || j>(c-1) then
        raise Size_unmatch
      else
       a.(i).(j)
    let unit n = init n n (fun i j -> if i=j then SemiRing.unit else SemiRing.zero)
    let zero m n = init m n (fun _ _ -> SemiRing.zero)
    let add (r1,c1,a) (r2,c2,b) = 
      if r1<>r2 || c1<>c2 then
        raise Size_unmatch
      else
        init r1 c1 (fun i j -> SemiRing.add a.(i).(j) b.(i).(j))
    let mul (r1,c1,a) (r2,c2,b) =
      let mul_sub i j =
        let rec mul_tailrec k sum=
          if k<c1 then
            mul_tailrec (k+1) (SemiRing.add sum (SemiRing.mul a.(i).(k) b.(k).(j)))
          else
            sum
        in
        mul_tailrec 0 SemiRing.zero
      in
      if c1<>r2 then
        raise Size_unmatch
      else
        init r1 c2 (fun i j -> mul_sub i j)
    let pow a k =
      let (r,c,_) = a in
      let rec pow_sub k =
        match k with
        | 0                    -> unit r
        | 1                    -> a
        | k  when k mod 2 = 0  -> let ak2 = pow_sub (k/2) in mul ak2 ak2
        | k(*when k mod 2 = 1*)-> let ak2 = pow_sub ((k-1)/2) in mul ak2 (mul ak2 a)
      in
      if r<>c then
        raise Size_unmatch
      else
        pow_sub k
  end

module IntMod =
  struct
    type t = int
    let m = 1000000007
    let add x y = (x+y) mod m
    let mul x y = (x*y) mod m
    let unit = 1
    let zero = 0
  end
module IntModMatrix = Matrix(IntMod)

module  Bool  =
  struct
    type t = bool
    let add x y = x || y
    let mul x y = x && y
    let unit = true
    let zero = false
  end
module BoolMatrix = Matrix(Bool)


type dist = Int of int | Inf
module MinPlus =
  struct 
    type t = dist
    let add x y =
      match (x,y) with
      |(Int x,Int y) -> if x<y then Int x else Int y
      |(Int x,Inf  ) -> Int x
      |(Inf  ,Int y) -> Int y
      |(Inf  ,Inf  ) -> Inf
    let mul x y =
      match (x,y) with
      |(Int x,Int y) -> Int (x+y)
      |(  _  ,  _  ) -> Inf
    let unit = Int 0
    let zero = Inf
  end
module MinPlusMatrix = Matrix(MinPlus)    

let fib n =
  let a = IntModMatrix.of_list
            [[1;1]
            ;[1;0]]
  in
  IntModMatrix.at (IntModMatrix.pow a n) 1 0

let fib_naive n =
  let rec fib_tailrec k fn1 fn =
    if k = n then
      fn
    else
      fib_tailrec (k+1) ((fn1+fn) mod 1000000007) fn1
  in
  fib_tailrec 0 1 0

let ans = fib       100000000
let ans_naive = fib_naive 100000000

let r = BoolMatrix.of_list
          [[ true;false;false; true]
          ;[ true;false;false;false]
          ;[false; true;false;false]
          ;[false; true;false;false]]
let _ = BoolMatrix.to_list r
let reflexive_transitive_closure_of_r = BoolMatrix.to_list(BoolMatrix.pow (BoolMatrix.add (BoolMatrix.unit 4) r) 4) 

let dist = MinPlusMatrix.of_list
             [[Inf  ;Int 10;Inf;Int 100  ]
             ;[Inf  ;Inf   ;Inf;Int 1000 ]
             ;[Inf  ;Int 1 ;Inf;Int 10000]
             ;[Int 5;Inf   ;Inf;Inf      ]]

let solve = MinPlusMatrix.to_list(MinPlusMatrix.pow (MinPlusMatrix.add (MinPlusMatrix.unit 4) dist) 4)
