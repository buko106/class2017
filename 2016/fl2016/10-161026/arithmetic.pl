/* arithmetic.pl */
add(z,Y,Y).
add(s(X),Y,s(Z)) :- add(X,Y,Z).

mult(_,z,z).
mult(X,s(Y),Z) :- add(X,XY,Z) , mult(X,Y,XY).
