module type STACK =
  sig
    type 'a t
    val empty : 'a t
    val pop : 'a t -> 'a * 'a t
    val push : 'a -> 'a t -> 'a t
    val size : 'a t -> int
  end

module Stack : STACK=
  struct
    type 'a t = 'a list
    let empty = []
    let pop s = match s with [] -> failwith "Empty" | hd::tl -> (hd,tl)
    let push a s = a :: s
    let rec size_tailrec s counter = match s with []-> counter | _::tl -> size_tailrec tl (counter+1)
    let size s = size_tailrec s 0
  end

module StackSize : STACK=
  struct
    type 'a t = 'a list * int
    let empty = ([],0)
    let pop (s,size) = match s with [] -> failwith "Empty" | hd::tl -> (hd,(tl,size-1))
    let push a (s,size) = (a::s,size+1)
    let size (_,size) = size
end
