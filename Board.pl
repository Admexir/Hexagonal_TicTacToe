:- module(board, [
    init_board/3,       % init_board(+Radius, +Obstacles, -Board)
    is_valid_coord/3,   % is_valid_coord(+Board, +Q, +R)
    get_cell/4,         % get_cell(+Board, +Q, +R, -State)
    set_cell/5,         % set_cell(+Board, +Q, +R, +State, -NewBoard)
    empty_cells/2       % empty_cells(+Board, -ListOfEmptyCoords)
]).
use_module(library(assoc)).

% initializes the starting configuration of the board
init_board(+Radius, +Obstacles, -Board).

% returns true when the coordinate is inside the board
is_valid_coord(+Board, +Q, +R).

% returns the state of a cell (which player owns it)
get_cell(+Board, +Q, +R, -State).

% sets the state of a cell (which player owns it)
set_cell(+Board, +Q, +R, +State, -NewBoard).

% returns a list of empty cells
empty_cells(+Board, -ListOfEmptyCoords).


% board could probably (?) be something like: board(Radius, AssocCells)
% where AssocCells is a map: c(Q,R) -> State