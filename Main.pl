/* test: 
consult('C:/Users/ajaza/source/repos/_Neprocko/Project/Main.pl').
start.
*/

:- use_module(board).
:- use_module(logic).
:- use_module(ai).
:- use_module(io).
:- use_module(library(random)). % for obstacle placement

start :-
    io:print_message('----- Hexagonal Tic Tac Toe -----'),
    % init query (search depth, grid size)
    % run init
    io:read_int_value('Enter AI search depth: ', SearchDepth),
    io:read_int_value('Enter board size radius: ', BoardSize),
    io:read_int_value('Enter board obstacle count: ', ObstacleCount),

    io:print_message('Type moves in the format: Q R or type exit to quit'),
    
    generate_random_coordinates(ObstacleCount, BoardSize, Obstacles),

    % for now, initialize with 3 diameter (sides 4 characters long) with obstacle in the middle
    board:init_board(BoardSize, Obstacles, Board),
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
        % board:empty_cells(Board, [(Q, R)|_]).
        ai:get_best_move(Board, ai, Depth, Q, R),
        io:print_message(['AI\'s move: ', Q, ', ', R]).

% helper to switch turns
next_player(player, ai).
next_player(ai, player).

% generates a list of Count coordinates in a grid of size Radius
% generate_random_coordinates(+Count, +Radius, -ObstacleList)
generate_random_coordinates(Count, Radius, ObstacleList) :-
    findall((Q, R), valid_hex_coord(Radius, Q, R), AllCoords), % not using board:is_valid_coord because that validates "overlaying" obstacles too
    
    % shuffle the list
    random_permutation(AllCoords, ShuffledCoords),
    
    % return required list
    take(Count, ShuffledCoords, ObstacleList).

valid_hex_coord(Radius, Q, R) :-
    Min is -Radius,
    Max is Radius,
    between(Min, Max, Q),
    between(Min, Max, R),
    S is -Q - R,
    abs(S) =< Radius.

take(0, _, []).
take(N, [H|T], [H|Rest]) :-
    N > 0,
    N1 is N - 1,
    take(N1, T, Rest).