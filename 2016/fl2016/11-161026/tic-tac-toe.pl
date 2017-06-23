rev(o,x).
rev(x,o).

same(X,X).
all(X,X,X,X).

there_exists_some_blank(A1, _, _, _, _, _, _, _, _) :- same(A1,b),!.
there_exists_some_blank( _,A2, _, _, _, _, _, _, _) :- same(A2,b),!.
there_exists_some_blank( _, _,A3, _, _, _, _, _, _) :- same(A3,b),!.
there_exists_some_blank( _, _, _,B1, _, _, _, _, _) :- same(B1,b),!.
there_exists_some_blank( _, _, _, _,B2, _, _, _, _) :- same(B2,b),!.
there_exists_some_blank( _, _, _, _, _,B3, _, _, _) :- same(B3,b),!.
there_exists_some_blank( _, _, _, _, _, _,C1, _, _) :- same(C1,b),!.
there_exists_some_blank( _, _, _, _, _, _, _,C2, _) :- same(C2,b),!.
there_exists_some_blank( _, _, _, _, _, _, _, _,C3) :- same(C3,b),!.

win(A1,A2,A3, _, _, _, _, _, _,P) :- all(P,A1,A2,A3),!.
win( _, _, _,B1,B2,B3, _, _, _,P) :- all(P,B1,B2,B3),!.
win( _, _, _, _, _, _,C1,C2,C3,P) :- all(P,C1,C2,C3),!.
win(A1, _, _,B1, _, _,C1, _, _,P) :- all(P,A1,B1,C1),!.
win( _,A2, _, _,B2, _, _,C2, _,P) :- all(P,A2,B2,C2),!.
win( _, _,A3, _, _,B3, _, _,C3,P) :- all(P,A3,B3,C3),!.
win(A1, _, _, _,B2, _, _, _,C3,P) :- all(P,A1,B2,C3),!.
win( _, _,A3, _,B2, _,C1, _, _,P) :- all(P,A3,B2,C1),!.
win(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    rev(P,Q),
    \+ all(Q,A1,A2,A3),
    \+ all(Q,B1,B2,B3),
    \+ all(Q,C1,C2,C3),
    \+ all(Q,A1,B1,C1),
    \+ all(Q,A2,B2,C2),
    \+ all(Q,A3,B3,C3),
    \+ all(Q,A1,B2,C3),
    \+ all(Q,A3,B2,C1),
    there_exists_win_move(A1,A2,A3,B1,B2,B3,C1,C2,C3,P).

there_exists_win_move(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(A1,b),rev(P,Q),lose(P,A2,A3,B1,B2,B3,C1,C2,C3,Q),!.
there_exists_win_move(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(A2,b),rev(P,Q),lose(A1,P,A3,B1,B2,B3,C1,C2,C3,Q),!.
there_exists_win_move(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(A3,b),rev(P,Q),lose(A1,A2,P,B1,B2,B3,C1,C2,C3,Q),!.
there_exists_win_move(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(B1,b),rev(P,Q),lose(A1,A2,A3,P,B2,B3,C1,C2,C3,Q),!.
there_exists_win_move(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(B2,b),rev(P,Q),lose(A1,A2,A3,B1,P,B3,C1,C2,C3,Q),!.
there_exists_win_move(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(B3,b),rev(P,Q),lose(A1,A2,A3,B1,B2,P,C1,C2,C3,Q),!.
there_exists_win_move(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(C1,b),rev(P,Q),lose(A1,A2,A3,B1,B2,B3,P,C2,C3,Q),!.
there_exists_win_move(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(C2,b),rev(P,Q),lose(A1,A2,A3,B1,B2,B3,C1,P,C3,Q),!.
there_exists_win_move(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(C3,b),rev(P,Q),lose(A1,A2,A3,B1,B2,B3,C1,C2,P,Q),!.


lose(A1,A2,A3, _, _, _, _, _, _,P) :- rev(P,Q) , all(Q,A1,A2,A3),!.
lose( _, _, _,B1,B2,B3, _, _, _,P) :- rev(P,Q) , all(Q,B1,B2,B3),!.
lose( _, _, _, _, _, _,C1,C2,C3,P) :- rev(P,Q) , all(Q,C1,C2,C3),!.
lose(A1, _, _,B1, _, _,C1, _, _,P) :- rev(P,Q) , all(Q,A1,B1,C1),!.
lose( _,A2, _, _,B2, _, _,C2, _,P) :- rev(P,Q) , all(Q,A2,B2,C2),!.
lose( _, _,A3, _, _,B3, _, _,C3,P) :- rev(P,Q) , all(Q,A3,B3,C3),!.
lose(A1, _, _, _,B2, _, _, _,C3,P) :- rev(P,Q) , all(Q,A1,B2,C3),!.
lose( _, _,A3, _,B2, _,C1, _, _,P) :- rev(P,Q) , all(Q,A3,B2,C1),!.
lose(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    there_exists_some_blank(A1,A2,A3,B1,B2,B3,C1,C2,C3),
    invalid_or_lose_move_A1(A1,A2,A3,B1,B2,B3,C1,C2,C3,P),
    invalid_or_lose_move_A2(A1,A2,A3,B1,B2,B3,C1,C2,C3,P),
    invalid_or_lose_move_A3(A1,A2,A3,B1,B2,B3,C1,C2,C3,P),
    invalid_or_lose_move_B1(A1,A2,A3,B1,B2,B3,C1,C2,C3,P),
    invalid_or_lose_move_B2(A1,A2,A3,B1,B2,B3,C1,C2,C3,P),
    invalid_or_lose_move_B3(A1,A2,A3,B1,B2,B3,C1,C2,C3,P),
    invalid_or_lose_move_C1(A1,A2,A3,B1,B2,B3,C1,C2,C3,P),
    invalid_or_lose_move_C2(A1,A2,A3,B1,B2,B3,C1,C2,C3,P),
    invalid_or_lose_move_C3(A1,A2,A3,B1,B2,B3,C1,C2,C3,P).

invalid_or_lose_move_A1(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(A1,b) , rev(P,Q) , win(P,A2,A3,B1,B2,B3,C1,C2,C3,Q).
invalid_or_lose_move_A1(A1, _, _, _, _, _, _, _, _,_) :-
    \+ same(A1,b).

invalid_or_lose_move_A2(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(A2,b) , rev(P,Q) , win(A1,P,A3,B1,B2,B3,C1,C2,C3,Q).
invalid_or_lose_move_A2( _,A2, _, _, _, _, _, _, _,_) :-
    \+ same(A2,b).

invalid_or_lose_move_A3(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(A3,b) , rev(P,Q) , win(A1,A2,P,B1,B2,B3,C1,C2,C3,Q).
invalid_or_lose_move_A3( _, _,A3, _, _, _, _, _, _,_) :-
    \+ same(A3,b).

invalid_or_lose_move_B1(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(B1,b) , rev(P,Q) , win(A1,A2,A3,P,B2,B3,C1,C2,C3,Q).
invalid_or_lose_move_B1( _, _, _,B1, _, _, _, _, _,_) :-
    \+ same(B1,b).

invalid_or_lose_move_B2(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(B2,b) , rev(P,Q) , win(A1,A2,A3,B1,P,B3,C1,C2,C3,Q).
invalid_or_lose_move_B2( _, _, _, _,B2, _, _, _, _,_) :-
    \+ same(B2,b).

invalid_or_lose_move_B3(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(B3,b) , rev(P,Q) , win(A1,A2,A3,B1,B2,P,C1,C2,C3,Q).
invalid_or_lose_move_B3( _, _, _, _, _,B3, _, _, _,_) :-
    \+ same(B3,b).

invalid_or_lose_move_C1(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(C1,b) , rev(P,Q) , win(A1,A2,A3,B1,B2,B3,P,C2,C3,Q).
invalid_or_lose_move_C1( _, _, _, _, _, _,C1, _, _,_) :-
    \+ same(C1,b).

invalid_or_lose_move_C2(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(C2,b) , rev(P,Q) , win(A1,A2,A3,B1,B2,B3,C1,P,C3,Q).
invalid_or_lose_move_C2( _, _, _, _, _, _, _,C2, _,_) :-
    \+ same(C2,b).

invalid_or_lose_move_C3(A1,A2,A3,B1,B2,B3,C1,C2,C3,P) :-
    same(C3,b) , rev(P,Q) , win(A1,A2,A3,B1,B2,B3,C1,C2,P,Q).
invalid_or_lose_move_C3( _, _, _, _, _, _, _, _,C3,_) :-
    \+ same(C3,b).



