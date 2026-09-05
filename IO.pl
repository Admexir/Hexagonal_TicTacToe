/* test:
consult('C:/Users/ajaza/source/repos/_Neprocko/Project/IO.pl').
consult('C:/Users/ajaza/source/repos/_Neprocko/Project/Board.pl').
use_module(board).
use_module(io).
init_board(2, [(0,0)], B0),
set_cell(B0,  1,  0, player, B1),
set_cell(B1,  0,  1, player, B2),
set_cell(B2, -1,  0, ai, B3),
set_cell(B3,  0, -1, ai, FinalBoard),
print_board(FinalBoard).
*/

/*
expected:
  . . . 
 . O . . 
. O # X . 
 . . X . 
  . . . 
B0 = board(2, t(c(0, -2), ...

*/


:- module(io, [
    print_board/1,      % print_board(+Board)
    read_player_move/3, % read_player_move(+Board, -Q, -R)
    print_message/1     % print_message(+Msg)
]).

:- use_module(board).
:- use_module(library(assoc)).

% map cell states to characters
state_char(empty, '.').
state_char(player, 'X').
state_char(ai, 'O').
state_char(obstacle, '#').

% prints out the board visuals
print_board(board(Radius, Assoc)) :-
    NegRad is -Radius,
    print_board_helper(board(Radius, Assoc), NegRad).
    
% recursive print of rows
print_board_helper(board(Radius, Assoc), Radius) :- print_row(board(Radius, Assoc), Radius),!.
print_board_helper(board(Radius, Assoc), CRow) :- 
    \+ Radius is CRow,
    NRow is CRow+1,
    print_row(board(Radius, Assoc), CRow),
    print_board_helper(board(Radius, Assoc), NRow).

% Prints a single row, applying an indent to create the hexagonal shape
print_row(board(Radius, Assoc), R) :-
    Indent is abs(R),
    tab(Indent),
    MinQ is max(-Radius, -Radius - R),
    MaxQ is min(Radius, Radius - R),
    forall(
        between(MinQ, MaxQ, Q),
        (   
            get_assoc(c(Q, R), Assoc, State),
            state_char(State, Char),
            write(Char), write(' ')
        )),
    write('\n').

% reads the user input
read_player_move(Board, Q, R) :-
    repeat,
    write('Enter move (Q R): '),
    flush_output,
    read_line_to_string(user_input, String),
    (   
        parse_move(String, TQ, TR),
        is_valid_coord(Board, TQ, TR),
        get_cell(Board, TQ, TR, empty)
            ->  Q = TQ, R = TR, ! %if
            ;   print_message('Invalid move (out of bounds, taken, or obstacle), try again...'),  %else
                fail
    ).

% extracts the coordinates from a string
parse_move(String, Q, R) :-
    split_string(String, " \t", " \t", [QString, RString]),
    number_string(Q, QString),
    number_string(R, RString).

% prints a message - for example win screen
print_message([W|Ws]) :-
    write(W), print_message(Ws).
print_message([]) :- write('\n'), !.
print_message(Msg) :-
    write(Msg), write('\n').
