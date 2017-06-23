append([], Y, Y).
append([A|X], Y, [A|Z]) :- append(X, Y, Z).

reverse([],[]).
reverse([HD|TL],RET) :- reverse(TL,X) , append(X,[HD],RET).

concat([],[]).
concat([HD|TL],RET) :- concat(TL,X) , append(HD,X,RET).


