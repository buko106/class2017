eq(a,b).
eq(c,b).
eq(X,Z) :- eq(X,Y),eq(Y,Z).
eq(X,Y) :- eq(Y,X).
