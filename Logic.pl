/* test: 
consult('C:/Users/ajaza/source/repos/_Neprocko/Project/Logic.pl').
use_module(board).
use_module(logic).
init_board(2, [], B0),
   get_neighbours(B0, 0, 0, Neighbours),
   set_cell(B0, -2, 0, player, B1),
   set_cell(B1, -1, 0, player, B2),
   set_cell(B2,  0, 0, player, B3),
   set_cell(B3,  1, 0, player, B4),
   \+ check_win(B4, NonWinner),
   set_cell(B4,  2, 0, player, B_Win),
   check_win(B_Win, Winner).
*/

/* expected: 
board(2,t(...)), 
Neighbours = [(1, 0), (0, 1), (1, -1), (-1, 0), (0, -1), (-1, 1)], 
... board prints ... 
Winner = player
*/
:- module(logic, [
    check_win/2,        % check_win(+Board, ?Player)
    check_draw/1,       % check_draw(+Board)
    get_neighbours/4,   % get_neighbours(+Board, +Q, +R, -Neighbours)
    direction/2         % direction(?Dir1, ?Dir2)
]).

:- use_module(board).
:- use_module(library(assoc)).

% hexagonal grid has 6 directions ( :) )
direction(1, 0).
direction(0, 1).
direction(1, -1).
direction(-1, 0).
direction(0, -1).
direction(-1, 1).

% to prevent empty spaces from winning
player(ai).
player(player).

% returns a list of all valid (Q, R) coordinates adjacent to the given cell
get_neighbours(Board, Q, R, Neighbours) :-
    findall(
        (NQ, NR),
        (   
            direction(DQ, DR),
            NQ is Q + DQ,
            NR is R + DR,
            is_valid_coord(Board, NQ, NR) % from board file (not registering  for some reason but works)
        ),
        Neighbours).

% checks whether a player has fulfilled a win condition (5 tiles in a row)
check_win(board(Radius, Assoc), Player) :-
    % the player has to be a player-state (not empty or obstacles)
    player(Player),
    
    % go through all tiles belonging to the player
    gen_assoc(c(Q, R), Assoc, Player),
    
    % pick one of the 3 positive axes to avoid checking the same line in reverse
    direction(DQ, DR),
    
    % continue checking along the line
    check_line(board(Radius, Assoc), Player, Q, R, DQ, DR, 5).

% helper function to check x tiles in a line
check_line(_, _, _, _, _, _, 0) :- !.  % found 5 in a row
% check_line(Board, Player, CurrentCoordinate1, CurrentCoordinate2, DirectionDelta1, DirectionDelta2, RemainingSteps)
check_line(Board, Player, Q, R, DQ, DR, Count) :-
    Count > 0,
    get_cell(Board, Q, R, Player), % returns true iff the player owns the tile at (Q, R)
    NextQ is Q + DQ,
    NextR is R + DR,
    NextCount is Count - 1,
    check_line(Board, Player, NextQ, NextR, DQ, DR, NextCount).

% checks whether a draw happened (no empty tiles)
check_draw(Board) :-
    \+ check_win(Board, player), % makes sure noone won before declaring a draw (maybe won't be needed based on the logic order in game loop...)
    \+ check_win(Board, ai),
    empty_cells(Board, []).