:- module(logic, [
    check_win/2,    % check_win(+Board, ?Player)
    check_draw/1    % check_draw(+Board)
]).
use_module(board).

% hexagonal grid has 3 axes
direction(1, 0).
direction(0, 1).
direction(1, -1).

% checks whether a player has fulfilled a win condition
check_win(+Board, ?Player).

% checks whether a draw happened (no empty tiles)
check_draw(+Board).