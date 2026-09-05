/* test: 
consult('C:/Users/ajaza/source/repos/_Neprocko/Project/Main.pl').
start.
*/

:- use_module(board).
:- use_module(logic).
:- use_module(ai).
:- use_module(io).

start :-
    io:print_message('----- Hexagonalni piskvorky -----'),
    % init query (search depth, grid size)
    % run init
    
    % for now, initialize with 3 diameter (sides 4 characters long) with obstacle in the middle
    board:init_board(3, [(0, 0)], Board),
    game_loop(Board, player).
    % run game loop

game_loop(Board, CurrentPlayer) :-
    % draw board
    io:print_board(Board),
    (   
        % check win con
        logic:check_win(Board, Winner) 
        ->  io:print_message(['Game Over, ', Winner, ' wins!'])
        ;   logic:check_draw(Board) 
        ->  io:print_message('Game Over! It is a draw!')
        ;   % if no win con fulfilled, query a move
            % get next move (AI or player IO)
            get_move(Board, CurrentPlayer, Q, R),
            % execute move (set cell)
            board:set_cell(Board, Q, R, CurrentPlayer, NewBoard),
            % update game loop logic
            next_player(CurrentPlayer, NextPlayer),
            game_loop(NewBoard, NextPlayer)
    ).

% gets the players move
get_move(Board, player, Q, R) :-
    io:read_player_move(Board, Q, R).
% gets the AI's move
get_move(Board, ai, Q, R) :-
    io:print_message('AI is thinking...'),
    % TODO: query ai move ; for now, return the first available cell
    board:empty_cells(Board, [(Q, R)|_]).

% helper to switch turns
next_player(player, ai).
next_player(ai, player).