type false_t = { t : 'a. 'a }
type 'a not_t = 'a -> false_t
type ('a, 'b) and_t = 'a * 'b
type ('a, 'b) or_t = L of 'a | R of 'b

let one f g =
  (fun x -> g (f x))

let two : ('a, ('b , 'c) and_t) or_t -> (('a, 'b) or_t , ('a, 'c) or_t) and_t =
  fun x ->
  match x with
  |L a-> (L a,L a)
  |R (b,c)-> (R b,R c)

let three :(('a, 'b) or_t ,('a, 'c) or_t) and_t -> ('a,('b,'c)and_t) or_t =
  fun (l,r) ->
  match l with
  |L a -> L a
  |R b->
    begin
      match r with
      |L a -> L a
      |R c -> R (b,c)
    end

let rec callcc
        :(('a -> false_t) -> 'a)->'a
  = fun f -> callcc f

let left : 'a -> ('a , 'a not_t) or_t
  = fun a -> L a

let right : ('a not_t) -> ('a ,'a not_t) or_t
  = fun na -> R na


(* let six : (('a->'b)->'a)->'a = *)
(*   fun f:(-> *)
(*   callcc f *)

(* カリーハワード同型によって型システムと直観主義論理との間の対応がある。またcallccやパース則を加えると古典論理と同等になることも知られている。1~3は簡単に示せるが、4,6は古典論理の恒真式なので難しい。5は古典論理でも示すことができない。4,6は証明図を書いて、記号論理での->の除去が関数適用・仮定の解消がclosure(fun式)に対応することを意識することで作れた。同封する画像はM1の原先輩が運用しているipc_bot(twitter.com/ipc_bot)が出力したものを引用しています。 *)
