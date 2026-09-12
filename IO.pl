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
    read_int_value/2,   % read_int_value(+Message, -Value)
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

    write('R\\Q'),
    % top axis indices
    RadM2 is Radius -2, tab(RadM2),
    write('\\'),
    forall(
        between(0, Radius, Q),
        format('~w\\', [Q])   % 'x '... exactly 2 characters
    ),
    write('\n'),
    
    print_board_helper(board(Radius, Assoc), NegRad),

    % bottom axis indices
    write('R\\Q '),
    tab(RadM2),
    write('\\'),
    forall(
        between(NegRad, 0, Q),
        (   
            Q < 0 
        ->  format('~w', [Q])  % '-5' ... exactly 2 characters
        ;   format('\\~w\\', [Q]) % '0 '
        )
    ),
    write('\n').
    
% recursive print of rows
print_board_helper(board(Radius, Assoc), Radius) :- print_row(board(Radius, Assoc), Radius),!.
print_board_helper(board(Radius, Assoc), CRow) :- 
    \+ Radius is CRow,
    NRow is CRow+1,
    print_row(board(Radius, Assoc), CRow),
    print_board_helper(board(Radius, Assoc), NRow).

% prints a single row, indenting to create the hexagonal shape
print_row(board(Radius, Assoc), R) :-
    % row numbering
    (   
        R < 0 
    ->  format('~w ', [R]) 
    ;   format(' ~w ', [R]) 
    ),
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
        String == "exit"
        ->  
        print_message('Exiting game...'), 
        halt
        ;   
        parse_move(String, TQ, TR),
        is_valid_coord(Board, TQ, TR),
        get_cell(Board, TQ, TR, empty)
        ->  
        Q = TQ, R = TR, ! 
        ;   
        print_message('Invalid move (out of bounds, taken, or obstacle), try again...'),  
        fail
    ).

% reads the user input at the start of the app to positive integer values
read_int_value(Message, Value) :-
    repeat,
    write(Message),
    flush_output,
    read_line_to_string(user_input, String),
    (   
        number_string(ParsedVal, String),
        integer(ParsedVal),
        ParsedVal > 0
        ->  Value = ParsedVal, ! %if
        ;   print_message('Invalid input, must be a positive integer, try again...'),  %else
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
