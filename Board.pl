% test: consult('C:/Users/ajaza/source/repos/_Neprocko/Project/Board.pl').
% use_module(board).
% init_board(1, [(0,1)], B),
%    get_cell(B, 0, 0, State00),
%    get_cell(B, 0, 1, State01),
%    set_cell(B, 0, 0, player, B_New),
%    get_cell(B_New, 0, 0, State00_New),
%    is_valid_coord(B, -1, 1),
%    \+ is_valid_coord(B, 2, 0).

% expected:
% B = board(1, t(c(-1, 0), empty, -, t(c(-1, 1), empty, -, ...
% State00 = empty,
% State01 = obstacle,
% B_New = board(1, t(c(-1, 0), empty, -, t(c(-1, 1), empty, -, ...
% State00_New = player.

:- module(board, [
    init_board/3,       % init_board(+Radius, +Obstacles, -Board)
    is_valid_coord/3,   % is_valid_coord(+Board, +Q, +R)
    get_cell/4,         % get_cell(+Board, +Q, +R, -State)
    set_cell/5,         % set_cell(+Board, +Q, +R, +State, -NewBoard)
    empty_cells/2       % empty_cells(+Board, -ListOfEmptyCoords)
]).
use_module(library(assoc)).

% The board is represented as: board(Radius, AssocCells)
% AssocCells maps c(Q, R) -> State

% % initializes the starting configuration of the board
% init_board(+Radius, +Obstacles, -Board).

% % returns true when the coordinate is inside the board
% is_valid_coord(+Board, +Q, +R).

% % returns the state of a cell (which player owns it)
% get_cell(+Board, +Q, +R, -State).

% % sets the state of a cell (which player owns it)
% set_cell(+Board, +Q, +R, +State, -NewBoard).

% % returns a list of empty cells
% empty_cells(+Board, -ListOfEmptyCoords).

% generates all coordinates
generate_hex_coords(Radius, Coords) :-
    NegRadius is -Radius,
    findall(
        c(Q, R),
        (   
            % a tile is in radius Rad iff |Q| <= Rad, |R| <= Rad, |Q + R| <= Rad
            between(NegRadius, Radius, Q),
            between(NegRadius, Radius, R),
            S is -Q-R,
            abs(S) =< Radius
        ),
        Coords).

% initializes the starting board
% (Obstacles == [(X, Y),...])
init_board(Radius, Obstacles, board(Radius, AssocCells)) :-
    generate_hex_coords(Radius, Coords),
    empty_assoc(EmptyAssoc),
    fill_board(Coords, Obstacles, EmptyAssoc, AssocCells).

% helper func to populate the board with empty states and obstacles
fill_board([], _, Assoc, Assoc).
fill_board([c(Q, R)|T], Obstacles, CurrentAssoc, FinalAssoc) :-
    (   member((Q, R), Obstacles)   % if
    ->  State = obstacle            % then
    ;   State = empty               % else
    ),
    put_assoc(c(Q, R), CurrentAssoc, State, NextAssoc),
    fill_board(T, Obstacles, NextAssoc, FinalAssoc).

% validate coordinates
% returns true iff coordinate is inside the board
is_valid_coord(board(Radius, _), Q, R) :-
    abs(Q) =< Radius,
    abs(R) =< Radius,
    abs(Q + R) =< Radius.


% get and set cells ------------------------------
% returns the state of a cell
get_cell(board(_, AssocCells), Q, R, State) :-
    get_assoc(c(Q, R), AssocCells, State).

% sets the state of a cell and returns a new board
set_cell(board(Radius, AssocCells), Q, R, State, board(Radius, NewAssocCells)) :-
    is_valid_coord(board(Radius, AssocCells), Q, R), % check the coord is valid
    put_assoc(c(Q, R), AssocCells, State, NewAssocCells).

% returns a list of empty cells
empty_cells(board(_, AssocCells), EmptyCoords) :-
    assoc_to_list(AssocCells, List),
    findall(
        (Q, R),
        (   
            member(c(Q, R)-State, List),
            State == empty
        ),
        EmptyCoords).
