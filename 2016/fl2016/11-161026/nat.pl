max(X,Y,X) :- X>Y , ! .
max(X,Y,Y).

nat(z).
nat(s(X)) :- nat(X).

nat_list([]).
nat_list([N|X]) :- nat(N) , nat_list(X) .
