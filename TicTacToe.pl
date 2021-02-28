/** 
 * Tic-Tac-Toe 3x3
 */
% player = hu, compputer = ai, empty place = 0
% use fill(9) before starting game 

/** Helper functions */
replace(List1, Index, Elem, List2) :-
    replace(List1, Index, Elem, List2, 0).

replace([A| List1], Index, Elem, List2, IndexCur) :-
    ( IndexCur = Index ->  List2 = [Elem | List1] ;
       Index1 is IndexCur + 1,  replace(List1, Index, Elem, List21, Index1),  List2 = [A | List21] ).

/** Simple implementation */

/** Basic info */
wins(State, E) :-
    State = [X11, X12, X13, X21, X22, X23, X31, X32, X33],
    ( X11 = E, X12 = E, X13 = E;
      X21 = E, X22 = E, X23 = E;
      X31 = E, X32 = E, X33 = E;
      X11 = E, X21 = E, X31 = E;
      X12 = E, X22 = E, X32 = E;
      X13 = E, X23 = E, X33 = E;
      X11 = E, X22 = E, X33 = E;
      X13 = E, X22 = E, X31 = E).

emptyBoard3x3([0,0,0,0,0,0,0,0,0]).

fill(0) :- !.
fill(X) :- asserta(i(X)), X1 is X - 1,  fill(X1).

/** Basic actions */
canMove(Board, I) :- nth0(I, Board, 0).

makeMove(Board, I, New, Board1) :- replace(Board, I, New, Board1).

opponent(hu, ai).
opponent(ai, hu).

loses(Board, P1) :- opponent(P1, P2), wins(Board, P2 ).

tie(Board) :- not(member(0, Board)).

whowon(hu) :- writeln('You win').
whowon(ai) :- writeln('Computer wins'). 
checkEndGame(Board, P) :-
    (wins(Board, P) -> whowon(P),  fail, !  ;
    (tie(Board) -> writeln('Its a tie'), fail, !  ; 1=1 )).

/** User interaction */
getVal(Prompt, Val) :-
    write(Prompt), read(Val1),
    (integer(Val1), Val1>0, Val1 <4 -> Val=Val1 ; getVal(Prompt, Val) ).

huMove(Board, I) :-
    getVal('Row:', Y), getVal('Col:', X),
    I1 is (Y-1) * 3 + (X-1),
    (canMove(Board, I1) -> I=I1 ; 
    writeln('Move not available'), huMove(Board, I) ).

showBoard(Board) :-
    writef('%t - %t - %t\n%t - %t - %t\n%t - %t - %t\n', Board).

/** Game setup */
play(Board) :-
    showBoard(Board), huMove(Board, Ihu), makeMove(Board, Ihu, hu, Board1),
    checkEndGame(Board1, hu),
    aiMove(Board1, Iai), makeMove(Board1, Iai, ai, Board2),
    checkEndGame(Board2, ai),
    play(Board2).

game() :- emptyBoard3x3(Board), play(Board).

/** Ai move algorythm */

% 1. - first available field
% aiMove(Board, I) :- i(I), canMove(Board, I), !.

