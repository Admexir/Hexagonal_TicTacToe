/* test: 
consult('C:/Users/ajaza/source/repos/_Neprocko/Project/Ai.pl').

test 1 - find_owned_tiles:
init_board(2, [], B0),
set_cell(B0, 0, 0, ai, B1),
set_cell(B1, 1, 0, ai, B2),
set_cell(B2, -1, 1, player, FinalBoard),
ai:find_owned_tiles(FinalBoard, ai, RawAITiles),
sort(RawAITiles, AITiles),
ai:find_owned_tiles(FinalBoard, player, PlayerTiles).

test 2 - generate_moves:
board:init_board(1, [(0,1)], B),
ai:generate_moves(B, [(0,0)], Moves).

test 3 - evaluate_board:
board:init_board(2, [], B0),
board:set_cell(B0, -1, 0, ai, B1),
ai:evaluate_board(B1, Score1),
board:set_cell(B1,  0, 0, ai, B2),
ai:evaluate_board(B2, Score2),
board:set_cell(B2,  1, 0, ai, FinalBoard),
ai:evaluate_board(FinalBoard, Score3).

test 4 - minimax spots a win condition:
board:init_board(2, [], B0),
board:set_cell(B0, -2, 0, ai, B1),
board:set_cell(B1, -1, 0, ai, B2),
board:set_cell(B2,  0, 0, ai, B3),
board:set_cell(B3,  1, 0, ai, FinalBoard),
ai:minimax(FinalBoard, 1, -10000000, 10000000, ai, BestEval, BestMove).

variation 2:
board:init_board(2, [], B0),
board:set_cell(B0, -2, 0, ai, B1),
board:set_cell(B1, -1, 0, ai, B2),
board:set_cell(B2,  1, 0, ai, FinalBoard),
ai:minimax(FinalBoard, 1, -10000000, 10000000, ai, BestEval, BestMove).

*/

/* expected:
test 1:
B0 = ..., B1 = ..., B2 = ..., FinalBoard = ...
AITiles = [(0, 0), (1, 0)],
PlayerTiles = [(-1, 1)].

test 2: 
B = board(...
Moves = [(-1, 0), (-1, 1), (0, -1), (1, -1), (1, 0)].

test 3:
B0 = ..., B1 = ..., B2 = ..., FinalBoard = ..., OwnedTiles = [(-1, 0), (0, 0), (1, 0)],
Score1 = 6. Score2 = 74. Score3 = 564.

test 4:
B0 = ..., B1 = ..., B2 = ..., B3 = ..., FinalBoard = ...,
BestEval = 1000000,
BestMove = (2, 0).

variation 2:
B0 = ..., B1 = ..., B2 = ..., FinalBoard = ...,
BestEval = 2616,
BestMove = (0, 0).

*/

:- module(ai, [
get_best_move/5,    % get_best_move(+Board, +Player, +Depth, -BestQ, -BestR)
generate_moves/3,   % generate_moves(+Board, +OccupiedTiles, -Moves)
evaluate_board/2    % evaluate_board(+Board, -Score)
]).

:- use_module(logic).
:- use_module(board).

% main predicate to get ai move - uses minimax to generate the best move
%get_best_move(+Board, +Player, +Depth, -BestQ, -BestR) :-
get_best_move(Board, Player, Depth, BestQ, BestR) :-
    ai:minimax(Board, Depth, -10000000, 10000000, ai, _, (BestQ, BestR)).

% helpers to separate maximizing and minimizing player
wanted_points_multiplier(player, -1).
wanted_points_multiplier(ai, 1). 
init_max(player, PosInf) :- PosInf is inf.
init_max(ai, NegInf) :- NegInf is -inf.
is_maximizing(ai, true).
is_maximizing(player, false).
next_player(player, ai).
next_player(ai, player).

% helpers to update alpha beta algorithm values
% max player new best move eval
update_best(true, Eval, Move, CurrentBest, _, Eval, Move) :- 
    Eval > CurrentBest, !.
% min player new best move eval
update_best(false, Eval, Move, CurrentBest, _, Eval, Move) :- 
    Eval < CurrentBest, !.
% not a new best move eval
update_best(_, _, _, CurrentBest, CurrentMove, CurrentBest, CurrentMove).
% update alpha (for max player)
update_alpha_beta(true, Best, Alpha, Beta, NewAlpha, Beta) :- 
    NewAlpha is max(Alpha, Best).
% update beta (for min player)
update_alpha_beta(false, Best, Alpha, Beta, Alpha, NewBeta) :- 
    NewBeta is min(Beta, Best).



% alpha beta minimax
% minimax(+Board, +Depth, +Alpha, +Beta, +Player, -BestEval, -BestMove)

% reached game end - ai won
minimax(Board, _, _, _, _, 1000000, null) :-
    logic:check_win(Board, ai), !.

% reached game end - player won
minimax(Board, _, _, _, _, -1000000, null) :-
    logic:check_win(Board, player), !.

% reached game end - draw
minimax(Board, _, _, _, _, 0, null) :-
    logic:check_draw(Board), !.

% reached max depth -> evaluate board
minimax(Board, 0, _, _, _, Eval, null) :-
    !,
    % find_owned_tiles(Board, Player, OwnedTiles),
    evaluate_board(Board, Eval).
    % wanted_points_multiplier(Player, Mult),
    % Eval is RawScore * Mult.

% intermediate node -> continue searching deeper
minimax(Board, Depth, Alpha, Beta, Player, BestEval, BestMove) :-
    next_player(Player, NextPlayer),
    find_owned_tiles(Board, Player, OwnedTiles),
    find_owned_tiles(Board, NextPlayer, OtherPlayerTiles),
    append(OwnedTiles, OtherPlayerTiles, OccupiedTiles),
    generate_moves(Board, OccupiedTiles, Moves),
    
    % get if the current player is maximizing or minimizing + initialize node value
    % wanted_points_multiplier(Player, Mult),
    init_max(Player, InitMinimum),
    is_maximizing(Player, IsMaximizing),
    

    % process all the generated moves (which calls minimax again after evaluating pruning/alpha beta logic)
    % process_moves(+Moves, +Board, +Depth, +Alpha, +Beta, +Player, +NextPlayer, +IsMaximizing, +CurrentBest, +CurrentMove, -BestEval, -BestMove)
    process_moves(Moves, Board, Depth, Alpha, Beta, Player, NextPlayer, IsMaximizing, InitMinimum, null, BestEval, BestMove).


% processes all the given moves (calls deeper minimax after evaluating pruning conditions, updates alpha/beta,...)
% process_moves(+Moves, +Board, +Depth, +Alpha, +Beta, +Player, +NextPlayer, +IsMaximizing, +CurrentBest, +CurrentMove, -FinalBest, -FinalMove)

% base case == all moves processed -> pass up current best moves
process_moves([], _, _, _, _, _, _, _, FinalBest, FinalMove, FinalBest, FinalMove).
% recursive case -> process a single move
process_moves([(Q, R)|RestMoves], Board, Depth, Alpha, Beta, Player, NextPlayer, IsMaximizing, CurrentBest, CurrentMove, FinalBest, FinalMove) :-
    % execute the move (on a "local board") and evaluate it
    board:set_cell(Board, Q, R, Player, NextBoard),
    NextDepth is Depth - 1,
    minimax(NextBoard, NextDepth, Alpha, Beta, NextPlayer, Eval, _),
    % we got evaluation of the move -> update best move + alpha/beta values if needed
    update_best(IsMaximizing, Eval, (Q, R), CurrentBest, CurrentMove, NewBest, NewMove),
    update_alpha_beta(IsMaximizing, NewBest, Alpha, Beta, NewAlpha, NewBeta),
    % check if we prune the branch -------------------------------------
    (   
        NewAlpha >= NewBeta % pruning condition: alpha >= beta
        ->  % prune
        FinalBest = NewBest,
        FinalMove = NewMove
        ;   % continue checking other nodes (on the same depth)
        process_moves(RestMoves, Board, Depth, NewAlpha, NewBeta, Player, NextPlayer, IsMaximizing, NewBest, NewMove, FinalBest, FinalMove)
    ).


    

% generates all possible moves of placing a move adjecent to another already taken tile
generate_moves(Board, OwnedTiles, Moves) :-
    findall(
        (DQ, DR),
        (
            member((Q, R), OwnedTiles),
            (DQ is Q + 1 ; DQ is Q - 1 ; DQ is Q),
            (DR is R + 1 ; DR is R - 1 ; DR is R),
            \+ (Q =:= DQ, R =:= DR),
            board:is_valid_coord(Board, DQ, DR),
            board:get_cell(Board, DQ, DR, empty)
        ),
        Moves1
    ),
    sort(Moves1, Moves). % remove duplicates



% finds all taken tiles by the ai on the board
find_owned_tiles(board(_, Assoc), Player, OwnedTiles) :- % very similar to empty_cells
    assoc_to_list(Assoc, List),
    findall(
        (Q, R),
        (   
            member(c(Q, R)-State, List),
            State == Player
        ),
        OwnedTiles).


% evaluates the board using a heuristic - all line lengths ^ 5 
% => the bot prioritizes longer lines over multiple shorter ones, but more of same length over fewer
evaluate_board(Board, Score) :-
    find_owned_tiles(Board, ai, AITiles),
    find_owned_tiles(Board, player, PlayerTiles),
    score_tiles(AITiles, AIScore),
    score_tiles(PlayerTiles, PlayerScore),
    Score is AIScore - PlayerScore.


% evaluates the given owned tiles
score_tiles(OwnedTiles, Score) :-
    findall(
        Length,
        (
            member((Q, R), OwnedTiles),
            logic:direction(DQ, DR),
            find_line_length(OwnedTiles, Q, R, DQ, DR, Length)
        ),
        LinesLength
        ),
    maplist(raise_to_fifth_power, LinesLength, PowLengths),
    sum_list(PowLengths, Score).


raise_to_fifth_power(In, Out) :- Out is In^5.



% helper for find_longest_line - returns length of one specific line
% find_line_length(+OwnedTiles, +Q, +R, +DQ, +DR, -Length)

% line search reached the end of a line
find_line_length(OwnedTiles, Q, R, _, _, 0) :- \+ member((Q, R), OwnedTiles).
find_line_length(OwnedTiles, Q, R, DQ, DR, Count) :-
    member((Q, R), OwnedTiles),
    NextQ is Q + DQ,
    NextR is R + DR,
    find_line_length(OwnedTiles, NextQ, NextR, DQ, DR, NextCount),
    Count is NextCount + 1.