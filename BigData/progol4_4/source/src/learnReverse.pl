%:- set(posonly), unset(cover), unset(condition)?
:- unset(cover)?
:- set(c,5)?
:- set(h,100)?
% we want learn rev/2 so we put a modeh clause.
:- modeh(1,rev(+isList,-isList))?
:- modeh(1,rev([+isconst],[-isConst]))?
:- modeh(1,rev([+isconst|+isList],[-isConst|-isList]))?
:- modeb(1,conc(+isList,+isList,-isList))?
:- modeb(1,conc([+isConst|+isList],+isList,[-isConst|-isList]))?
:- modeb(1,+isList = [])?
:- modeb(1,rev(+islist,-isList))?
:- modeb(1,rev([+isconst|+isList],[-isConst|-isList]))?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Types: we have to give type to parameters using a Prolog style

isList([]).
isList([H|T]) :- isConst(H), isList(T).

isConst(a).  isConst(b).  isConst(c).  isConst(d).  isConst(e).  isConst(f).
isConst(g).  isConst(h).  isConst(i).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% background
conc([],L,L).
conc([X|L1],L2,[X|L3])  :- conc(L1,L2,L3).
%%%%%%%%%%%%%%%%%%%%%%
% Positive examples
rev([],[]).
rev([i],[i]).
rev([a],[a]).
rev([i],[i]).
rev([i,a],[a,i]).
rev([c],[c]).
rev([d],[d]).
rev([e],[e]).
rev([f],[f]).
rev([g],[g]).
rev([h],[h]).
rev([a,b,c],[c,b,a]).
rev([i,b,c,d],[d,c,b,i]).
rev([a,b,h,d,e],[e,d,h,b,a]).
:-rev([],[a]).
:-rev([a],[b]).
:-rev([a,b],[a,b]).
rev([b,a],[a,b]).
rev([a,b,c,d,e,a],[a,e,d,c,b,a]).
rev([a,b,c,d,f],[f,d,c,b,a]).
rev([a,b,c,d,g],[g,d,c,b,a]).
