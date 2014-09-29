conc([],A,A).

conc([A|B],C,[A|D]) :- conc(B,C,D).
