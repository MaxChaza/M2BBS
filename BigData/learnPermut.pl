%:- set(posonly), unset(cover), unset(condition)?
:- unset(cover)?
:- set(c,5)?
:- set(h,100)?
% we want learn permut/2 so we put a modeh clause.
:- modeh(1,permut(+isList,-isList))?
:- modeh(1,permut([+isConst|+isList],-isList))?
:- modeb(1,insert(+isConst,+isList,[-isConst|-isList]))?
:- modeb(1,insert(+isConst,[+isConst|+isList],[-isConst|-isList]))?
:- modeb(1,+isList = [])?
:- modeb(1,permut(+islist,-isList))?
:- modeb(1,permut([+isconst|+isList],-isList))?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Types: we have to give type to parameters using a Prolog style

isList([]).
isList([H|T]) :- isConst(H), isList(T).

isConst(a).  isConst(b).  isConst(c).  isConst(d).  isConst(e).  isConst(f).
isConst(g).  isConst(h).  isConst(i).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% background
insert(X,L,[X|L]).
insert(X,[Y|L],[Y|L1]):- insert(X,L,L1).
%%%%%%%%%%%%%%%%%%%%%%
% Positive examples
permut([],[]).
permut([a,b],[b,a]).
permut([a,b,c,d,e],[e,d,c,b,a]).
permut([a,b,c,d,e],[e,c,d,b,a]).
permut([a,b,c,d,e],[e,c,d,a,b]).
:-permut([],[a]).
:-permut([a,b,c],[a,b,c]).
:-permut([a,b],[a,b]).


