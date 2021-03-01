/** 
 * Tic-Tac-Toe 3x3
 */
% player = hu, compputer = ai, empty place = 0
% use fill(8) before starting game 

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

fill(-1) :- !.
fill(X) :- asserta(i(X)), X1 is X - 1,  fill(X1).

/** Basic actions */
canMove(Board, I) :- i(I), nth0(I, Board, 0).

makeMove(Board, I, New, Board1) :- replace(Board, I, New, Board1).

opponent(hu, ai).
opponent(ai, hu).

loses(Board, P1) :- opponent(P1, P2), wins(Board, P2 ).

filled(Board) :- not(member(0, Board)).

whowon(hu) :- writeln('You win').
whowon(ai) :- writeln('Computer wins'). 
checkEndGame(Board, P) :-
    (wins(Board, P) -> whowon(P),  fail, !  ;
    (filled(Board) -> writeln('Its a tie'), fail, !  ; 1=1 )).

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
    checkEndGame(Board1, hu), !,
    aiMove(Board1, Iai), makeMove(Board1, Iai, ai, Board2),
    checkEndGame(Board2, ai), !, 
    play(Board2).

game() :- emptyBoard3x3(Board), play(Board).

/** Ai move algorithm */

/** 
 * 1. - first available field
 */
%  aiMove(Board, I) :- canMove(Board, I), !.

/** 
 * 2. - presumably AI and player make their best moves,
 *      NegMax algorithm considers all alternatives 
 *      git tag: all_alternatives_search
 */
%  aiMove(Board, I) :-
%     search(Board, ai, I, _), !.

/**
 * 3. - cuts off branches that are bound to have 
 *      worse result than already got
 *      NegMax + ALphaBeta 
 */
aiMove(Board, I) :-
     search(Board, ai, -10000, 10000, I, _), !.
/**
 * estimate max score for all available moves 
 * if for some move of these moves 
 * MaxPlayerScore will be >= MaxOpponentScore, than
 * BestScore for this player will also be >= MaxOpponentScore
 * and when we return one step back Opponent will definitely
 * not pick this branch,
 * as it tries to minimize next Player score,
 * so we can already cut it off
 */
exploreMoves(_, _, _, _, [], []).
exploreMoves(_, _, MaxPlayer, MaxOpponent, _, []) :-
    MaxPlayer >= MaxOpponent, !.

exploreMoves(Board, Player, MaxPlayer, MaxOpponent, [Move| Moves], [Score|Scores1]) :-
    exploreMove(Board, Player, MaxPlayer, MaxOpponent, Move, Score),
    MaxPlayer1 is max(MaxPlayer, Score),
    exploreMoves(Board, Player, MaxPlayer1, MaxOpponent, Moves, Scores1).

/**
 * estimate max score on this board:
 * make move -> create next virtual board
 * search for best opponent score for new board
 * the less is Opponent`s score the greater is Player`s score 
 * changing sign of scores, as for nect score() Player (Opponent) 
 * its benefitial score must always be positive and loss - negative
 */
exploreMove(Board, Player, MaxPlayer, MaxOpponent, Move, Score) :-
    makeMove(Board, Move, Player, Board1),
    opponent(Player, Opponent),
    MaxOpponentNeg is -MaxOpponent, MaxPlayerNeg is -MaxPlayer,
    search(Board1, Opponent, MaxOpponentNeg, MaxPlayerNeg, _, ScoreNeg),
    Score is -ScoreNeg.

/**
 * If board is filled
 * then evaluate winner
 * as it is checked beforehand that ai will have at least one field available
 * it wont ever be initial search() call
 */
search(Board, Player, _, _, _, BestScore) :-
    filled(Board),
    ( wins(Board, Player) -> BestScore is 10 ;
    ( opponent(Player, Player2), wins(Board, Player2) -> BestScore is -10;
      BestScore is 0)).

/**
 * find all available moves
 * get max possible scores after each move
 * find max score
 * find index of max score
 * get move that led to this score
 */
search(Board, Player, MaxPlayer, MaxOpponent, BestMove, BestScore) :-
    findall(I, canMove(Board, I), Moves),
    exploreMoves(Board, Player, MaxPlayer, MaxOpponent, Moves, Scores), 
    max_member(BestScore, Scores),
    nth0(I, Scores, BestScore), 
    nth0(I, Moves, BestMove).








