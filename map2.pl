:- dynamic pos/3.
max_x(4).
max_y(4).
pos(1, 1, [free]).
pos(1, 2, [stench]).
pos(1, 3, [pit]).
pos(1, 4, [breeze]).
pos(2, 1, [stench]).
pos(2, 2, [breeze]).
pos(2, 3, [breeze]).
pos(2, 4, [free]).
pos(3, 1, [wumpus, breeze]).
pos(3, 2, [breeze, stench, pit]).
pos(3, 3, [pit]).
pos(3, 4, [breezej]).
pos(4, 1, [stench]).
pos(4, 2, [breeze]).
pos(4, 3, [breeze]).
pos(4, 4, [gold]).