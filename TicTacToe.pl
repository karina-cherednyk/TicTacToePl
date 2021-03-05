/** 
 * Tic-Tac-Toe 3x3
 */
% player = hu, compputer = ai, empty place = 0
% use fill(8) before starting game 
:- consult('TicTacToeScore').

/** Simple implementation */

/** Basic info */
canMove(b(Board,_,Cols), m(R,C)) :- 
    r(R), c(C),
    I is (R-1)*Cols + (C-1),
    nth0(I, Board, 0).

fill(-1) :- !.
fill(X) :- asserta(i(X)), X1 is X - 1,  fill(X1).

/** Basic actions */

opponent(hu, ai).
opponent(ai, hu).

wins(Score) :- Score >=  10^6.
loses(Score) :- Score =< -10^6.

filled(b(Board,_,_)) :- not(member(0, Board)).

whowon(hu) :- writeln('You win').
whowon(ai) :- writeln('Computer wins'). 
checkEndGame(Board, Score, P) :-
    (wins(Score) -> whowon(P),  fail, !  ;
    (filled(Board) -> writeln('Its a tie'), fail, !  ; 1=1 )).

/** User interaction */
getVal(Prompt, Val) :-
    write(Prompt), read(Val1),
    (integer(Val1), Val1>0, Val1 <11 -> Val=Val1 ; getVal(Prompt, Val) ).

huMove(Board, Move, Score) :-
    getVal('Row:', R), getVal('Col:', C),
    Move1 = m(R,C),
    (canMove(Board, Move1) -> 
        Move=Move1, makeEvalMove(Board, Move1, x, Score) ; 
        writeln('Move not available'), huMove(Board, Move, Score) ).

getFormat(R, C, R, C, '%t\n') :- !.
getFormat(R, C, Ri, Ci, F) :- 
    (Ci=C -> 
        R1 is Ri+1, C1 is 1, S='%t\n'; 
        R1 is Ri, C1 is Ci + 1, S='%t' ),
    getFormat(R,C,R1, C1, F1),
    atom_concat(S,F1,F).

showBoard(b(Board,R,C)) :-
    getFormat(R,C,1,1,F),
    writef(F, Board).

/** Game setup */
play(Board) :-
    showBoard(Board), 
    huMove(Board, Mvhu, ScoreHu), 
    makeMove(Board, Mvhu, x, Board1),
    checkEndGame(Board1, ScoreHu, x), !,
    

    aiMove(Board1, Mvai, ScoreAi), 
    makeMove(Board1, Mvai, o, Board2),
    checkEndGame(Board2, ScoreAi, o), !, 
    

    play(Board2).

game() :- emptyBoard10x10(Board), play(Board).

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
aiMove(Board, I, Score) :-
     search(Board, 1, 2, o, -10000, 10000, I, Score), !.
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
exploreMoves(_, _, _, _, _, _, [], []).
exploreMoves(_, _,_,_, MaxPlayer, MaxOpponent, _, []) :-
    MaxPlayer >= MaxOpponent, !.

exploreMoves(Board, Depth, MaxDepth, Player, MaxPlayer, MaxOpponent, [Move| Moves], [Score|Scores1]) :-
    exploreMove(Board, Depth, MaxDepth, Player, MaxPlayer, MaxOpponent, Move, Score),
    MaxPlayer1 is max(MaxPlayer, Score),
    exploreMoves(Board, Depth, MaxDepth, Player, MaxPlayer1, MaxOpponent, Moves, Scores1).

/**
 * estimate max score on this board:
 * make move -> create next virtual board
 * search for best opponent score for new board
 * the less is Opponent`s score the greater is Player`s score 
 * changing sign of scores, as for nect score() Player (Opponent) 
 * its benefitial score must always be positive and loss - negative
 */
exploreMove(Board, Depth, MaxDepth, Player, MaxPlayer, MaxOpponent, Move, Score) :-
    makeMove(Board, Move, Player, Board1),
    opp(Player, Opponent),
    Depth1 is Depth + 1,
    MaxOpponentNeg is -MaxOpponent, MaxPlayerNeg is -MaxPlayer,
    ( (Depth1>=MaxDepth ; filled(Board)) ->  
        moveTotalScore(Board, Move, Player, Score) ;
        ( search(Board1, Depth1, MaxDepth, Opponent, MaxOpponentNeg, MaxPlayerNeg, _, ScoreNeg),
         Score is -ScoreNeg )).



/**
 * find all available moves
 * get max possible scores after each move
 * find max score
 * find index of max score
 * get move that led to this score
 */
search(Board, Depth, MaxDepth, Player, MaxPlayer, MaxOpponent, BestMove, BestScore) :-
    bestMoves(Board, Player, Moves),
    exploreMoves(Board, Depth, MaxDepth, Player, MaxPlayer, MaxOpponent, Moves, Scores), 
    max_member(BestScore, Scores),
    nth0(I, Scores, BestScore), 
    nth0(I, Moves, BestMove).








