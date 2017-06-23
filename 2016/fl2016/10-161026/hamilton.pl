
/* my_select( e , E , E\ {e} ) */
my_select( X , [X|Xs] , Xs ).
my_select( X , [Y|Ys] ,[Y|Zs]) :- my_select(X,Ys,Zs).

/* path(スタート,残っている頂点集合、使っていない辺集合) */
path(_,[],_). % 成功
path(S,VS,ES) :- my_select(V,VS,VREST) ,
                 my_select((S,V),ES,EREST) ,
                 path(V,VREST,EREST).

hamilton(V,E) :- my_select(S,V,VREST) ,
                 path(S,VREST,E).
