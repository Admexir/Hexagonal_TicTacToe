:- module(io, [
    print_board/1,      % print_board(+Board)
    read_player_move/3, % read_player_move(+Board, -Q, -R)
    print_message/1     % print_message(+Msg)
]).

% prints out the board visuals
print_board(+Board).

% reads the user input
read_player_move(+Board, -Q, -R).

% prints a message - for example win screen
print_message(+Msg).