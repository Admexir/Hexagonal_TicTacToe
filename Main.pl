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
    io:read_int_value('Enter AI search depth: ', SearchDepth),
    io:read_int_value('Enter board size radius: ', BoardSize),
    io:read_int_value('Enter board obstacle count: ', ObstacleCount),
    
    % for now, initialize with 3 diameter (sides 4 characters long) with obstacle in the middle
    % TODO: generate obstacles at random locations
    board:init_board(BoardSize, [(0, 0)], Board),
    % run game loop
    game_loop(Board, player, SearchDepth).

game_loop(Board, CurrentPlayer, AISearchDepth) :-
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
            get_move(Board, CurrentPlayer, AISearchDepth, Q, R),
            % execute move (set cell)
            board:set_cell(Board, Q, R, CurrentPlayer, NewBoard),
            % update game loop logic
            next_player(CurrentPlayer, NextPlayer),
            game_loop(NewBoard, NextPlayer, AISearchDepth)
    ).

% gets the players move
get_move(Board, player, _, Q, R) :-
    io:read_player_move(Board, Q, R).
% gets the AI's move
get_move(Board, ai, Depth, Q, R) :-
    io:print_message('AI is thinking...'),
    % TODO: query ai move ; for now, return the first available cell
    % board:empty_cells(Board, [(Q, R)|_]).
    ai:get_best_move(Board, ai, Depth, Q, R).

% helper to switch turns
next_player(player, ai).
next_player(ai, player).