% class/2

class(A,bird) :- homeothermic(A), has_eggs(A).
class(A,mammal) :- has_milk(A).
class(A,fish) :- has_gills(A).
class(A,reptile) :- not(has_gills(A)), has_eggs(A).

