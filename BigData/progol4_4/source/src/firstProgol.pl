:- modeh(1,concatene(+islist,+islist,-islist))?
:- modeh(1,concatene(+islist,+islist,-islist))?

% Background:Nothing.	

concatene([],[a],[a]).
concatene([a,b],[b,a],[a,b,b,a]).
concatene([a],[a],[a]).
concatene([b],[b,a],[a,b,b,a]).
concatene([b],[b,a],[a]).
concatene([a,b],[b,a],[a,b,a]).
concatene([a,b],[b,a],[b,a]).
concatene([b],[b],[a]).
concatene([],[b,a],[a,b,b,a]).
