%:- set(posonly), unset(cover), unset(condition)?
:- unset(cover)?
:- set(c,1)?
:- set(h,100)?
% we want learn conc/3 so we put a modeh clause.
:- modeh(1,conc([+isConst|+isList],+isList,[-isConst|-isList]))?
:- modeh(1,conc(+isList,+isList,-isList))?
% with what we want to learn
:- modeb(1,+isList = [])?
:- modeb(1,conc(+isList,+isList,-isList))?
:- modeb(1,conc([+isConst|+isList],+isList,[-isConst|-isList]))?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Types: we have to give type to parameters using a Prolog style

isList([]).
isList([H|T]) :- isConst(H), isList(T).

isConst(a).  isConst(b).  isConst(c).  isConst(d).  isConst(e).  isConst(f).
isConst(g).  isConst(h).  isConst(i).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Positive examples
conc([],[d],[d]).
conc([],[a,b],[a,b]).
%conc([a,b],[f,c],[a,b,f,c]).
conc([],[c],[c]).
conc([],[i,h],[i,h]).
conc([],[h],[h]).
%conc([c,f],[c],[c,f,c]).
%conc([],[],[]).
%conc([g,e],[c,d,a,c],[g,e,c,d,a,c]).
%conc([h],[d,a,h,d,g],[h,d,a,h,d,g]).
%conc([b,a],[],[b,a]).
%conc([e,c,g],[g],[e,c,g,g]).
%conc([],[],[]).
%conc([],[g,h],[g,h]).
%conc([],[],[]).
%conc([],[e],[e]).
%conc([a,c],[i,e],[a,c,i,e]).
%conc([c],[],[c]).
%conc([],[],[]).
%conc([],[],[]).
%conc([],[b,a],[b,a]).
%conc([],[],[]).
%conc([],[d],[d]).
%conc([],[a,a],[a,a]).
%conc([],[i],[i]).
%conc([g,e],[g,g,g,c,f],[g,e,g,g,g,c,f]).
%conc([],[b],[b]).
%conc([a,a,c,d],[],[a,a,c,d]).
%conc([c],[],[c]).
%conc([b],[c,c,h,f],[b,c,c,h,f]).
%conc([c,h,d,a,f,d,d,i],[a,a],[c,h,d,a,f,d,d,i,a,a]).
%conc([c,f,e],[],[c,f,e]).
%conc([],[],[]).
%conc([],[],[]).
%conc([f],[b],[f,b]).
%conc([g,h],[],[g,h]).
%conc([],[],[]).
%conc([c],[a],[c,a]).
%conc([],[c,e],[c,e]).
%conc([],[i],[i]).
%conc([h,a],[f,h,f,f],[h,a,f,h,f,f]).
%conc([d,a],[i,a,c,a],[d,a,i,a,c,a]).
% conc([],[],[]).
:-conc([1],[2],[2]).
