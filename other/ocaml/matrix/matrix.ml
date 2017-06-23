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
    type t = int * int * SemiRing.t array array
    type vector = int * SemiRing.t array
    val init_vector : int -> (int -> SemiRing.t) -> vector
    val init : int -> int -> (int -> int -> SemiRing.t) -> t
    val matrix_of_array : SemiRing.t array array -> t
    val unit : int -> t
    val zero : int -> int -> t
    val add : t -> t -> t
    val mul : t -> t -> t
    val pow : t -> int -> t
  end

module Matrix : MATRIX= 
  functor ( SemiRing : SEMIRING ) ->
  struct
    type t = int * int * SemiRing.t array array
    type vector = int * SemiRing.t array
    exception Size_unmatch
    let init_vector size f = (size,Array.init size f)
    let init row column f = (row,column,
                             Array.init row (fun r -> Array.init column (f r)))
    let matrix_of_array a = 
      let r = Array.length a in
      if r <= 0 then
        raise Size_unmatch
      else
        let c = Array.length a.(0) in
        let rec check i =
          if i = r then
            (r,c,a)
          else if c = Array.length a.(i) then
            check (i+1)
          else
            raise Size_unmatch
        in check 0
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
      if r<>c then
        raise Size_unmatch
      else
        let rec pow_tailrec k =
          match k with
          | k when k<0 -> raise (Invalid_argument "negative in function \"pow\"")
          | k when k=0 -> unit r
          | k when k mod 2 = 0 -> let ak2 = pow_tailrec (k/2) in mul ak2 ak2
          | k(*when k mod 2 =1*)-> let ak2 = pow_tailrec ((k-1)/2) in mul a (mul ak2 ak2)
        in 
        pow_tailrec k
  end

module Int =
  struct
    type t = int
    let add a b = a + b
    let mul a b = a * b
    let unit = 1
    let zero = 0
  end

module IntMatrix = Matrix(Int)

module IntMod  =
  struct
    type t = int
    let m = 1000000007
    let add a b = (a + b) mod m
    let mul a b = (a * b) mod m
    let unit = 1
    let zero = 0
  end

module IntModMatrix = Matrix(IntMod)

let fib n =
  let (_,_,ans) = IntModMatrix.pow (IntModMatrix.init 2 2(fun i j -> if i=1 && j=1 then 0 else 1)) n in ans.(1).(0)

let fib2 n =
  let rec fib2_tailrec fn1 fn n =
    if n = 0 then
      fn
    else fib2_tailrec ((fn1+fn) mod 1000000007) fn1 (n-1)
  in fib2_tailrec 1 0 n

let a = fib   100000000
let b = fib2  100000000
let aEqualb = a=b
