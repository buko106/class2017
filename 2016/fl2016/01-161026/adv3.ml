let add m n =
  fun f x-> m f (n f x)

let mul m n =
  fun f -> m (n f)

let rec encode n =
  if n=0 then
    fun f x->x
  else
    fun f x->encode (n-1) f (f x)

let decode m =
  m (fun x->x+1) 0

let sub m n =
  let a = decode m in
  let b = decode n in
  if a<b then
    encode 0
  else
    encode (a-b)
