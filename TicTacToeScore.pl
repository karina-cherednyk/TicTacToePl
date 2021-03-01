:- consult(initData).

getCell(b(Board, W, _), m(R,C), Val) :- 
        r(R), c(C), 
        I is (R-1) * W + (C-1), nth0(I, Board, Val).

countFilled(_,_,_, 0, TotalN, TotalN,0) :- !. 

% count x if still no gap met
countBranches(B, Pl, Mv, D, Pl,  Left, n(N,NRes), m(M, MRes), K ) :-
    M=N, N1 is N + 1, M1 is M + 1,
    count(B, Mv, D, Pl,  Left, n(N1,NRes), m(M1, MRes), K), !.

% count X  after gap
countBranches(B, Pl, Mv, D, Pl,  Left, N, m(M, MRes), k(K,KRes) ) :-
    K1 is K + 1, M1 is M + 1,
    count(B, Mv, D, Pl,  Left, N, m(M1, MRes), k(K1, KRes)), !.

% count all moves
countBranches(B, _, Mv, D, Pl,  Left, N, m(M, MRes), K ) :-
    M1 is M + 1,
    count(B, Mv, D, Pl,  Left, N, m(M1, MRes), K), !.

count(_, _, _, _, 0, n(NRes, NRes), m(MRes, MRes), k(KRes,KRes)) :- !.
count(B, m(R,C), d(DR,DC), Pl,  Left, N, M, K ) :- 
    Left1 is Left - 1,
    R1 is R + DR, C1 is C + DC,
    % if this move is not blocked by opp or board borders
    ( getCell(B, m(R, C), Val), not(opp(Pl,Val)) -> 
            countBranches(B, Val, m(R1,C1), d(DR,DC), Pl, Left1, N, M, K) ;
            count(_, _, _, _, 0, N, M, K ) ). % else stop by limiting moves


evalMove(B, Mv, Pl, d(DR, DC), Score) :-
    DRNeg is -DR, DCNeg is -DC,
    count(B, Mv, d(DR, DC), Pl, 5, n(0,NR), m(0, MR), k(0,KR)),
    count(B, Mv, d(DRNeg,DCNeg), Pl, 5, n(0,NL), m(0, ML), k(0,KL)),
    N is NR + NL - 1, M is MR + ML - 1, K is KR + KL,
    ( M < 5 -> Score=0 ; Score is 10^N * (M + 1) * 2*(K + 1)).

evalMove(B, Mv, Pl, Score) :-
    evalMove(B, Mv, Pl, d(0, 1), ScH),    % horizontally
    evalMove(B, Mv, Pl, d(1, 0), ScV),    % vertically
    evalMove(B, Mv, Pl, d(1, 1), ScDNW),  % diagonally North-West
    evalMove(B, Mv, Pl, d(1, -1), ScDNE), % diagonally North-East
    Score is ScH + ScV + ScDNW + ScDNE.
    

emptyNeighbor(B, Pl,  m(R1, C1)) :-
    getCell(B,m(R,C),Pl),        % iterate over every x cell
    d(DR), d(DC), 
    R1 is DR + R, C1 is DC + C,  % iterate over every x cell neighbor
    getCell(B, m(R1, C1), 0).


allMoves(B,Pl,Res) :-
    setof(M1, emptyNeighbor(B, Pl, M1), Res).



makeMove(b(B,W,H), m(R,C), Pl, b(B1,W,H)) :- 
    I is (R-1) * W + (C-1),
    replace(B, I, Pl, B1).

mapMoves(_, _, [], []).
mapMoves(B, Pl, [Mv|Moves], Res) :- 
    makeMove(B, Mv, Pl, B1),
    evalMove(B1,Mv,Pl, Score),
    ScoreNeg is -Score, % negation for keysort
    mapMoves(B, Pl, Moves, Tail),
    ( Score is 0 -> Res=Tail; Res=[ScoreNeg-Mv|Tail] ).
    

bestMoves(B, Pl, SortedMoves):-
    allMoves(B, Pl, AvMoves),
    mapMoves(B, Pl, AvMoves, KeyValMoves),
    keysort(KeyValMoves, SortedKeyVals),
    pairs_values(SortedKeyVals, SortedMoves).
    



