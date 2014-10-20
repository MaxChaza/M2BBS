%:- set(posonly), unset(cover), unset(condition)?
:- unset(cover)?
:- set(c,5)?
:- set(h,100)?

% we want learn rev so we put a modeh clause.
:- modeh(1,rev(+isList,-isList))?
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
% Training set

% Positive examples
rev([],[]).
rev([a,b],[b,a]).
rev([a],[a]).
rev([a,b,c],[c,b,a]).
rev([a,b,c,d],[d,c,b,a]).
rev([a,b,c,d,e],[e,d,c,b,a]).
rev([a,b,c,d,e,f],[f,e,d,c,b,a]).
rev([a,b,c,d,e,f,g],[g,h,e,d,c,b,a]).
rev([b,a],[a,b]).
rev([a,b,c,d,e,a],[a,e,d,c,b,a]).
rev([a,b,c,d,f],[f,d,c,b,a]).
rev([a,b,c,d,g],[g,d,c,b,a]).
%rev([c,d,e],[e,d,c]).
rev([a,b,c,d,e,f,g,h,i],[i,h,g,f,e,d,c,b,a]).
rev([i,h,a],[a,h,i]).
rev([d,a,c,a,e],[e,a,c,a,d]).
rev([i,d],[d,i]).
rev([i,c,d,e,a],[a,e,d,c,i]).
rev([h,g,i],[i,g,h]).
rev([h,g,i,a],[a,i,h,g]).
rev([h,g,i],[i,g,h]).
rev([i,c,d,e,a,b],[b,a,e,d,c,i]).
rev([d,e,a],[a,e,d]).
rev([i,c],[c,i]).
rev([d,e],[e,d]).
rev([i,a],[a,i]).
rev([i,d],[d,i]).
rev([c,f],[f,c]).
rev([b,c,d],[d,c,b]).
rev([e,c,d],[d,c,e]).
rev([f,c,d],[d,c,f]).
rev([g,c,d],[d,c,g]).
rev([d,c,d],[d,c,d]).

% Negative examples
:-rev([],[a]).
:-rev([a],[b]).
:-rev([a,b],[a,b]).
:-rev([c,d,e],[e,c,d]).
:-rev([d,a,c,b],[b,a,c,d]).
:-rev([i,j,c,d,e],[e,d,c,i,j]).
:-rev([h,g,i],[i,h,g]).
:-rev([h,g,i],[h,i,g]).

