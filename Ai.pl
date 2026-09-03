:- module(ai, [
    get_best_move/5,    % get_best_move(+Board, +Player, +Depth, -BestQ, -BestR)
    generate_moves/3,   % generate_moves(+Board, +Player, -Moves)
    evaluate_board/3    % evaluate_board(+Board, +Player, -Score)
]).

use_module(logic).
use_module(board).

% alpha beta minimax
minimax(+Board, +Depth, +Alpha, +Beta, +IsMaximizingPlayer, -Eval, -BestMove).

% uses minimax to generate the best move
get_best_move(+Board, +Player, +Depth, -BestQ, -BestR).

% generates all possible moves of placing a move adjecent to another already taken tile
generate_moves(+Board, +Player, -Moves).

% evaluates the board using some heuristic
evaluate_board(+Board, +Player, -Score).