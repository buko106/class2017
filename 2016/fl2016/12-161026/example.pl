sub(X,z,X) :- true.
sub(s(X),s(Y),Z) :- sub(X,Y,Z).
