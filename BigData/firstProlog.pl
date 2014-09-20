dern([X],X).
dern([Y|L],X):-dern(L,X).

/* Concatener 2 lignes */
concate([],L,L).
concate([X|L1],L2,[X|L3]):- concate(L1,L2,L3).
/*
 concate(X,Y,[1,2,3]). => Renvoie les hypothèses possibles
 concate([1,2,3],[Y,b,c],Z). => Concatène les deux listes dans Z



 Insertion 
 */
insert(X,L,[X|L]).
insert(X,[Y|L],[Y|L1]):-insert(X,L,L1).
/* 
insert(1,[a,e,2],Z).
Z = [1, a, e, 2].




 Permutation
*/
permut([],[]).
permut([X|L],L1):-permut(L,L2),insert(X,L2,L1).

/*
 permut([a,e,2,O],A).




Tri
issorted([]).
mysort([],[]).
mysort(L,L1):-permut(L,L1),issorted(L1).

*/

partitionner(X,[],[],[]).
partitionner(X,[Y|L],[Y|L1],L2):- X>=Y ,partitionner(X,L,L1,L2).
partitionner(X,[Y|L],L1,[Y|L2]):- X<Y ,partitionner(X,L,L1,L2).

quicksort([],[]).
quicksort([X|L],L1):-partitionner(X,L,L2,L3),
						quicksort(L2,L4),
						quicksort(L3,L6),
						concate(L4,[X|L6],L1).
						
/* NQueens */
solution([]).
solution([reine(X,Y)|Rs]):-
	solution(Rs),
	element(Y,[1,2,3,4,5,6,7,8]),
	nonattaque(reine(X,Y),Rs).

nonattaque(Reine,[]).
nonattaque(Reine,[R|Rs]):-
	nondiagouligne(Reine,R),
	nonattaque(Reine, Rs).

nondiagouligne(reine(I,J),reine(I1,J1)):-
	J \= J1,
	N1 is I+J1, N2 is I1+J,  N1 \= N2,
	N3 is I+J,  N4 is I1+J1, N3 \= N4.

element(X,[X|L]).
element(X,[Y|L]):-
	element(X,L).

soluce([reine(1,_),reine(2,_),reine(3,_),reine(4,_),reine(5,_),reine(6,_),reine(7,_),reine(8,_)]).

trouver(X) :-
	soluce(X),solution(X).
	
/* dans l'interpreteur saisir : trouver(X).*/





