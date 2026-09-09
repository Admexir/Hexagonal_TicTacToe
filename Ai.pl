/* 
test: consult('C:/Users/ajaza/source/repos/_Neprocko/Project/Ai.pl').


*/

:- module(ai, [
    get_best_move/5,    % get_best_move(+Board, +Player, +Depth, -BestQ, -BestR)
    generate_moves/3,   % generate_moves(+Board, +Player, -Moves)
    evaluate_board/3    % evaluate_board(+Board, +Player, -Score)
]).

use_module(logic).
use_module(board).

% helpers to separate maximizing and minimizing player
wanted_points_multiplier(player, -1).
wanted_points_multiplier(ai, 1). 
init_max(player, inf).
init_max(ai, NegInf) :- NegInf is -inf.
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

% reached max depth -> get evaluation
minimax(Board, 0, _Alpha, _Beta, Player, Eval, null) :-
    !,
    find_owned_tiles(Board, Player, OwnedTiles),
    evaluate_board(Board, OwnedTiles, RawScore),
    wanted_points_multiplier(Player, Mult),
    Eval is RawScore * Mult.
% reached a leaf node (game ended)
minimax(Board, Depth, _Alpha, _Beta, Player, Eval, null) :-
    (logic:check_win(Board, _) ; logic:check_draw(Board)),
    !,
    find_owned_tiles(Board, Player, OwnedTiles),
    evaluate_board(Board, OwnedTiles, RawScore),
    wanted_points_multiplier(Player, Mult),
    Eval is RawScore * Mult.

% intermediate node -> continue searching deeper
minimax(Board, Depth, Alpha, Beta, Player, BestEval, BestMove) :-
    find_owned_tiles(Board, Player, OwnedTiles),
    generate_moves(OwnedTiles, Moves),
    
    
    % get if the current player is maximizing or minimizing + initialize node value
    wanted_points_multiplier(Player, Mult),
    init_max(Player, InitMinimum),
    
    next_player(Player, NextPlayer),

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


% uses minimax to generate the best move
get_best_move(+Board, +Player, +Depth, -BestQ, -BestR).

get_current_move(Board, Player, BestMove) :-
    find_owned_tiles(Board, Player, OwnedTiles), % could cache it to not recalculate it every round...
    generate_moves(OwnedTiles, Moves),
    wanted_points_multiplier(Player, Mult),
    findall(
        Val,
        (
            member(Move, Moves),
            evaluate_board(Board, [Move|OwnedTiles], Player, Score),
            MultScore is Score * Mult,
            Val = Move/Score
        ),
        RatedMoves
        ),
    



% generates all possible moves of placing a move adjecent to another already taken tile
generate_moves(OwnedTiles, Moves) :-
    findall(
        (DQ, DR),
        (
            member(Q, OwnedTiles),
            member(R, OwnedTiles),
            DQ is Q + 1 ; DQ is Q - 1 ; DQ is Q,
            DR is R + 1 ; DR is R - 1 ; DR is R,
            \+ (Q is DQ && R is DR), 
        ),
        Moves
    )



% finds all taken tiles by the ai on the board
find_owned_tiles(Board, Player, OwnedTiles) :- % very similar to empty_cells
    assoc_to_list(Board, List),
    findall(
        (Q, R),
        (   
            member(c(Q, R)-State, List),
            State == Player
        ),
        OwnedTiles).


% evaluates the board using a heuristic - all line lengths ^ 5 
% => the bot prioritizes longer lines over multiple shorter ones, but more of same length over fewer
evaluate_board(Board, OwnedTiles, Score) :-
    findall(
        Length,
        (
            member((Q, R), OwnedTiles),
            direction(DQ, DR),
            find_line_length(OwnedTiles, Q, R, DQ, DR, Length)
        ),
        LinesLength
    ),
    maplist(raise_to_fifth_power, LinesLength, PowLengths),
    sum_list(PowLengths, Score).

raise_to_fifth_power(In, Out) :- Out is In^5.



% helper for find_longest_line - returns length of one specific line
find_line_length(_, _, _, _, _, 0). % line search reached the end of a line
find_line_length(OwnedTiles, Q, R, DQ, DR, Count) :-
    get_cell(Board, Q, R, ai), % returns true iff the player owns the tile at (Q, R)
    NextQ is Q + DQ,
    NextR is R + DR,
    NextCount is Count - 1,
    find_line_length(Board, ai, NextQ, NextR, DQ, DR, NextCount).