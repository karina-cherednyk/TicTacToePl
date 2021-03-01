% table rows
r(1).
r(2).
r(3).
r(4).
r(5).

% table columns
c(1).
c(2).
c(3).
c(4).
c(5).
c(6).
c(7).
c(8).
c(9).
c(10).

% players` move representation in game
opp(x,o).
opp(o,x).

% cell`s neighbors search values
d(-1).
d(1).
d(0).

% test data
b5(b(Board,10,5)) :-
    Board=[0,0,x,x,x, 0,0,x,o,0,
           0,0,0,0,0, 0,0,0,0,0,
           0,0,0,0,0, 0,0,0,0,0,
           0,0,0,0,0, 0,0,0,0,0,
           0,0,0,0,0, 0,0,0,0,0].


/** Helper functions */
replace(List1, Index, Elem, List2) :-
    replace(List1, Index, Elem, List2, 0).

replace([A| List1], Index, Elem, List2, IndexCur) :-
    ( IndexCur = Index ->  List2 = [Elem | List1] ;
       Index1 is IndexCur + 1,  replace(List1, Index, Elem, List21, Index1),  List2 = [A | List21] ).
