(* give names to intermediate values (K-normalization) *)

type t = (* K��������μ� (caml2html: knormal_t) *)
  | Unit
  | Int of int
  | Float of float
  | Neg of Id.t
  | Add of Id.t * Id.t
  | Sub of Id.t * Id.t
  | FNeg of Id.t
  | FAdd of Id.t * Id.t
  | FSub of Id.t * Id.t
  | FMul of Id.t * Id.t
  | FDiv of Id.t * Id.t
  | IfEq of Id.t * Id.t * t * t (* ��� + ʬ�� (caml2html: knormal_branch) *)
  | IfLE of Id.t * Id.t * t * t (* ��� + ʬ�� *)
  | Let of (Id.t * Type.t) * t * t
  | Var of Id.t
  | LetRec of fundef * t
  | App of Id.t * Id.t list
  | Tuple of Id.t list
  | LetTuple of (Id.t * Type.t) list * Id.t * t
  | Get of Id.t * Id.t
  | Put of Id.t * Id.t * Id.t
  | ExtArray of Id.t
  | ExtFunApp of Id.t * Id.t list
and fundef = { name : Id.t * Type.t; args : (Id.t * Type.t) list; body : t }

let rec fv = function (* ���˽и�����ʼ�ͳ�ʡ��ѿ� (caml2html: knormal_fv) *)
  | Unit | Int(_) | Float(_) | ExtArray(_) -> S.empty
  | Neg(x) | FNeg(x) -> S.singleton x
  | Add(x, y) | Sub(x, y) | FAdd(x, y) | FSub(x, y) | FMul(x, y) | FDiv(x, y) | Get(x, y) -> S.of_list [x; y]
  | IfEq(x, y, e1, e2) | IfLE(x, y, e1, e2) -> S.add x (S.add y (S.union (fv e1) (fv e2)))
  | Let((x, t), e1, e2) -> S.union (fv e1) (S.remove x (fv e2))
  | Var(x) -> S.singleton x
  | LetRec({ name = (x, t); args = yts; body = e1 }, e2) ->
      let zs = S.diff (fv e1) (S.of_list (List.map fst yts)) in
      S.diff (S.union zs (fv e2)) (S.singleton x)
  | App(x, ys) -> S.of_list (x :: ys)
  | Tuple(xs) | ExtFunApp(_, xs) -> S.of_list xs
  | Put(x, y, z) -> S.of_list [x; y; z]
  | LetTuple(xs, y, e) -> S.add y (S.diff (fv e) (S.of_list (List.map fst xs)))

let insert_let (e, t) k = (* let��������������ؿ� (caml2html: knormal_insert) *)
  match e with
  | Var(x) -> k x
  | _ ->
      let x = Id.gentmp t in
      let e', t' = k x in
      Let((x, t), e, e'), t'

let rec g env = function (* K�������롼�������� (caml2html: knormal_g) *)
  | Syntax.Unit -> Unit, Type.Unit
  | Syntax.Bool(b) -> Int(if b then 1 else 0), Type.Int (* ������true, false������1, 0���Ѵ� (caml2html: knormal_bool) *)
  | Syntax.Int(i) -> Int(i), Type.Int
  | Syntax.Float(d) -> Float(d), Type.Float
  | Syntax.Not(e) -> g env (Syntax.If(e, Syntax.Bool(false), Syntax.Bool(true)))
  | Syntax.Neg(e) ->
      insert_let (g env e)
	(fun x -> Neg(x), Type.Int)
  | Syntax.Add(e1, e2) -> (* ­������K������ (caml2html: knormal_add) *)
      insert_let (g env e1)
	(fun x -> insert_let (g env e2)
	    (fun y -> Add(x, y), Type.Int))
  | Syntax.Sub(e1, e2) ->
      insert_let (g env e1)
	(fun x -> insert_let (g env e2)
	    (fun y -> Sub(x, y), Type.Int))
  | Syntax.Add_poly(e1, e2) ->
       let _,t1 as g1 = g env e1 in
       insert_let g1
         (fun x -> let _,t2 as g2 = g env e2 in
                   insert_let g2
             (fun y -> match t1,t2 with
                       | Type.Int,Type.Int -> Add(x,y), Type.Int
                       | Type.Float,Type.Float -> FAdd(x,y), Type.Float
                       | _,_ -> failwith (Printf.sprintf "operator +# expects same type of int or float")))
  | Syntax.Sub_poly(e1, e2) ->
       let _,t1 as g1 = g env e1 in
       insert_let g1
         (fun x -> let _,t2 as g2 = g env e2 in
                   insert_let g2
             (fun y -> match t1,t2 with
                       | Type.Int,Type.Int -> Sub(x,y), Type.Int
                       | Type.Float,Type.Float -> FSub(x,y), Type.Float
                       | _,_ -> failwith (Printf.sprintf "operator -# expects same type of int or float")))
  | Syntax.FNeg(e) ->
      insert_let (g env e)
	(fun x -> FNeg(x), Type.Float)
  | Syntax.FAdd(e1, e2) ->
      insert_let (g env e1)
	(fun x -> insert_let (g env e2)
	    (fun y -> FAdd(x, y), Type.Float))
  | Syntax.FSub(e1, e2) ->
      insert_let (g env e1)
	(fun x -> insert_let (g env e2)
	    (fun y -> FSub(x, y), Type.Float))
  | Syntax.FMul(e1, e2) ->
      insert_let (g env e1)
	(fun x -> insert_let (g env e2)
	    (fun y -> FMul(x, y), Type.Float))
  | Syntax.FDiv(e1, e2) ->
      insert_let (g env e1)
	(fun x -> insert_let (g env e2)
	    (fun y -> FDiv(x, y), Type.Float))
  | Syntax.Eq _ | Syntax.LE _ as cmp ->
      g env (Syntax.If(cmp, Syntax.Bool(true), Syntax.Bool(false)))
  | Syntax.If(Syntax.Not(e1), e2, e3) -> g env (Syntax.If(e1, e3, e2)) (* not�ˤ��ʬ�����Ѵ� (caml2html: knormal_not) *)
  | Syntax.If(Syntax.Eq(e1, e2), e3, e4) ->
      insert_let (g env e1)
	(fun x -> insert_let (g env e2)
	    (fun y ->
	      let e3', t3 = g env e3 in
	      let e4', t4 = g env e4 in
	      IfEq(x, y, e3', e4'), t3))
  | Syntax.If(Syntax.LE(e1, e2), e3, e4) ->
      insert_let (g env e1)
	(fun x -> insert_let (g env e2)
	    (fun y ->
	      let e3', t3 = g env e3 in
	      let e4', t4 = g env e4 in
	      IfLE(x, y, e3', e4'), t3))
  | Syntax.If(e1, e2, e3) -> g env (Syntax.If(Syntax.Eq(e1, Syntax.Bool(false)), e3, e2)) (* ��ӤΤʤ�ʬ�����Ѵ� (caml2html: knormal_if) *)
  | Syntax.Let((x, t), e1, e2) ->
      let e1', t1 = g env e1 in
      let e2', t2 = g (M.add x t env) e2 in
      Let((x, t), e1', e2'), t2
  | Syntax.Var(x) when M.mem x env -> Var(x), M.find x env
  | Syntax.Var(x) -> (* ��������λ��� (caml2html: knormal_extarray) *)
      (match M.find x !Typing.extenv with
      | Type.Array(_) as t -> ExtArray x, t
      | _ -> failwith (Printf.sprintf "external variable %s does not have an array type" x))
  | Syntax.LetRec({ Syntax.name = (x, t); Syntax.args = yts; Syntax.body = e1 }, e2) ->
      let env' = M.add x t env in
      let e2', t2 = g env' e2 in
      let e1', t1 = g (M.add_list yts env') e1 in
      LetRec({ name = (x, t); args = yts; body = e1' }, e2'), t2
  | Syntax.App(Syntax.Var(f), e2s) when not (M.mem f env) -> (* �����ؿ��θƤӽФ� (caml2html: knormal_extfunapp) *)
      (match M.find f !Typing.extenv with
      | Type.Fun(_, t) ->
	  let rec bind xs = function (* "xs" are identifiers for the arguments *)
	    | [] -> ExtFunApp(f, xs), t
	    | e2 :: e2s ->
		insert_let (g env e2)
		  (fun x -> bind (xs @ [x]) e2s) in
	  bind [] e2s (* left-to-right evaluation *)
      | _ -> assert false)
  | Syntax.App(e1, e2s) ->
      (match g env e1 with
      | _, Type.Fun(_, t) as g_e1 ->
	  insert_let g_e1
	    (fun f ->
	      let rec bind xs = function (* "xs" are identifiers for the arguments *)
		| [] -> App(f, xs), t
		| e2 :: e2s ->
		    insert_let (g env e2)
		      (fun x -> bind (xs @ [x]) e2s) in
	      bind [] e2s) (* left-to-right evaluation *)
      | _ -> assert false)
  | Syntax.Tuple(es) ->
      let rec bind xs ts = function (* "xs" and "ts" are identifiers and types for the elements *)
	| [] -> Tuple(xs), Type.Tuple(ts)
	| e :: es ->
	    let _, t as g_e = g env e in
	    insert_let g_e
	      (fun x -> bind (xs @ [x]) (ts @ [t]) es) in
      bind [] [] es
  | Syntax.LetTuple(xts, e1, e2) ->
      insert_let (g env e1)
	(fun y ->
	  let e2', t2 = g (M.add_list xts env) e2 in
	  LetTuple(xts, y, e2'), t2)
  | Syntax.Array(e1, e2) ->
      insert_let (g env e1)
	(fun x ->
	  let _, t2 as g_e2 = g env e2 in
	  insert_let g_e2
	    (fun y ->
	      let l =
		match t2 with
		| Type.Float -> "create_float_array"
		| _ -> "create_array" in
	      ExtFunApp(l, [x; y]), Type.Array(t2)))
  | Syntax.Get(e1, e2) ->
      (match g env e1 with
      |	_, Type.Array(t) as g_e1 ->
	  insert_let g_e1
	    (fun x -> insert_let (g env e2)
		(fun y -> Get(x, y), t))
      | _ -> assert false)
  | Syntax.Put(e1, e2, e3) ->
      insert_let (g env e1)
	(fun x -> insert_let (g env e2)
	    (fun y -> insert_let (g env e3)
		(fun z -> Put(x, y, z), Type.Unit)))

let f e = fst (g M.empty e)

let print_space n = print_string (String.make (2*n) ' ')
let rec print t n =
  match t with
  | Unit -> (print_space n ;print_string "Unit")
  | Int i-> print_1 (string_of_int i)  n "Int"
  | Float f->print_1 (string_of_float f) n "Float"
  | Neg id -> print_1 id n "Neg"
  | Add (id1,id2) -> print_2 id1 id2 n "Add"
  | Sub (id1,id2) -> print_2 id1 id2 n "Sub"
  | FNeg id-> print_1 id n "FNeg"
  | FAdd (id1,id2)-> print_2 id1 id2 n "FAdd"
  | FSub (id1,id2)-> print_2 id1 id2 n "FSub"
  | FMul (id1,id2)-> print_2 id1 id2 n "FMul"
  | FDiv (id1,id2)-> print_2 id1 id2 n "FDiv"
  | IfEq (id1,id2,t1,t2) -> (print_2 id1 id2 n "IfEq" ;
                             print_string "\n" ;
                             print t1 (n+1) ;
                             print_string "\n" ;
                             print t2 (n+1) ;)
  | IfLE (id1,id2,t1,t2) -> (print_2 id1 id2 n "IfLE" ;
                             print_string "\n" ;
                             print t1 (n+1) ;
                             print_string "\n" ;
                             print t2 (n+1) ;)
  | Let (idt,t1,t2) -> (print_space n;
                        print_string "Let ";
                        print_id_type idt;
                        print_string "\n" ;
                        print t1 (n+1);
                        print_string "\n";
                        print t2 (n+1);)
  | Var id -> print_1 id n "Var"
  | LetRec (fundef,t) -> (print_space n;
                          print_string "LetRec\n" ;
                          print_space (n+1);
                          print_id_type fundef.name ;
                          print_string "\n";
                          print_space n; print_string " ";
                          List.map (fun x->print_string " ";print_id_type x) fundef.args ;
                          print_string "\n";
                          print fundef.body (n+1);
                          print_string "\n";
                          print t (n+1);)
  | App (id,idlist) -> (print_1 id n "App" ;
                        List.map (fun x->print_string (" "^x)) idlist;
                        () ; )
  | Tuple idlist -> (print_space n ;
                     print_string "Tuple";
                     List.map (fun x->print_string (" "^x)) idlist ;
                     () ;)
  | LetTuple (idtlist,id,t) -> (print_space n;
                                print_string "LetTuple";
                                List.map (fun idt->print_string " " ;print_id_type idt) idtlist ;
                                print_string "\n";
                                print t (n+1) ; )
  | Get (id1,id2) -> print_2 id1 id2 n "Get"
  | Put (id1,id2,id3) -> print_3 id1 id2 id3 n "Put"
  | ExtArray id -> print_1 id n "ExtArray"
  | ExtFunApp (id,idlist) -> (print_1 id n "ExtFunApp" ;
                              List.map (fun x->print_string (" "^x)) idlist ;
                              () ) ;

and print_1 id n tag = (print_space n;
                        print_string (tag^" "^id))
and print_2 id1 id2 n tag = (print_space n;
                             print_string (tag^" "^id1^" "^id2))
and print_3 id1 id2 id3 n tag = (print_space n;
                             print_string (tag^" "^id1^" "^id2^" "^id3))
and print_id_type (id,ty) = (print_string id;
                             print_string ":" ;
                             Type.print_type ty)