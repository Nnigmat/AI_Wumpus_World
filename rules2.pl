:- ensure_loaded('map.pl').
:- dynamic queue/1.
:- dynamic visited/1.
:- dynamic edge/1.
:- dynamic pits/1.
:- dynamic wumpus/1.
:- dynamic good/1.

queue([[1, 1]]).
visited([]).
edge([]).
pits([]).
wumpus(unknown).

start :-
    queue(Arr),
    (Arr \== [] ->
        queue([[X, Y]|Rest]),
        retract(queue([[X, Y]|Rest])), assert(queue(Rest)),
        retract(visited(Vis)), assert(visited([[X, Y]|Vis])),
        pos(X, Y, Props),
        (member(free, Props) -> 
            add_ok_cells(X, Y)
        ;member(gold, Props) ->
            stop
        ;
            edge(Edge), retract(edge(Edge)), assert(edge([[X, Y]|Edge]))
        )
    ;
        try_luck
    ),
    start. 

add_ok_cells(X, Y) :-
    max_x(Max_x), 
    max_y(Max_y),
    visited(Vis), 
    (
        Temp1 is X - 1, Temp1 \== 0 -> \+ member([Temp1, Y], Vis), 
        queue(Arr1), retract(queue(Arr1)), assert(queue([[Temp1, Y]|Arr1]));
        1 = 1
    ),
    (
        Temp2 is X + 1, Temp2 \== Max_x -> \+ member([Temp2, Y], Vis),
        queue(Arr2), retract(queue(Arr2)), assert(queue([[Temp2, Y]|Arr2]));
        1 = 1
    ),
    (
        Temp3 is Y - 1, Temp3 \== 0 -> \+ member([X, Temp3], Vis),
        queue(Arr3), retract(queue(Arr3)), assert(queue([[X, Temp3]|Arr3])); 
        1 = 1
    ),
    (
        Temp4 is Y + 1, Temp4 \== Max_y -> \+ member([X, Temp4], Vis),
        queue(Arr4), retract(queue(Arr4)), assert(queue([[X, Temp4]|Arr4]));
        1 = 1
    ).
   
try_luck :-
    edge([[X, Y]|Res]),
    visited(Vis),
    Temp1 is X + 1,
    Temp2 is Y + 1,
    Temp3 is X - 1,
    Temp4 is Y - 1,
    (
        \+ member([Temp1, Y], Vis) ->
            pos(Temp1, Y, Props), 
            (member(free, Props) ->
                add_ok_cells(X+1, Y)
            ; member(pit, Props) ->
                pits(Pits), retract(pits(Pits)), assert(pits([Temp1, Y|Pits]))
            ; member(wumpus, Props) ->
                retract(wumpus(unknown)), assert(wumpus([Temp1, Y]))
            ;
                adj(Temp1, Y, N), 
                (N == 2 ->
                    edge(Edge), retract(edge(Edge)), assert(edge([[Temp1, Y]|Edge]))
                ; N == 3 ->
                    append(Res, [[Temp1, Y]], Temp), retract(edge(_)), assert(edge(Temp))
                )
            )
        ;\+ member([X, Temp2], Vis) ->
            pos(X, Temp2, Props), 
            (member(free, Props) ->
                add_ok_cells(X, Temp2)
            ; member(pit, Props) ->
                pits(Pits), retract(pits(Pits)), assert(pits([X, Temp2|Pits]))
            ; member(wumpus, Props) ->
                retract(wumpus(unknown)), assert(wumpus([X, Temp2]))
            ;
                adj(X, Temp2, N), 
                (N == 2 ->
                    edge(Edge), retract(edge(Edge)), assert(edge([[X, Temp2]|Edge]))
                ; N == 3 ->
                    append(Res, [[X, Temp2]], Temp), retract(edge(_)), assert(edge(Temp))
                )
            )
        ;\+ member([Temp3, Y], Vis) ->
            pos(Temp3, Y, Props), 
            (member(free, Props) ->
            add_ok_cells(Temp3, Y)
            ; member(pit, Props) ->
                pits(Pits), retract(pits(Pits)), assert(pits([Temp3, Y|Pits]))
            ; member(wumpus, Props) ->
                retract(wumpus(unknown)), assert(wumpus([Temp3, Y]))
            ;
                adj(Temp3, Y, N), 
                (N == 2 ->
                    edge(Edge), retract(edge(Edge)), assert(edge([[Temp3, Y]|Edge]))
                ; N == 3 ->
                    append(Res, [[Temp3, Y]], Temp), retract(edge(_)), assert(edge(Temp))
                )
            )
        ;\+ member([X, Temp4], Vis) ->
            pos(X, Temp4, Props), 
            (member(free, Props) ->
            add_ok_cells(X, Temp4)
            ; member(pit, Props) ->
                pits(Pits), retract(pits(Pits)), assert(pits([X, Temp4|Pits]))
            ; member(wumpus, Props) ->
                retract(wumpus(unknown)), assert(wumpus(X, Temp4))
            ;
                adj(X, Temp4, N), 
                (N == 2 ->
                    edge(Edge), retract(edge(Edge)), assert(edge([[X, Temp4]|Edge]))
                ; N == 3 ->
                    append(Res, [[X, Temp4]], Temp), retract(edge(_)), assert(edge(Temp))
                )
            )
        ).

adj(X, Y, N) :-
    pos(X, Y, Props),
    max_x(Max_x), 
    max_y(Max_y),
    visited(Vis), 
    assert(good(0)),
    Temp1 is X - 1,
    Temp2 is X + 1,
    Temp3 is Y - 1,
    Temp4 is Y + 1,
    (
        Temp1 == 0 -> good(Z1), retract(good(Z1)), Z1_t is Z1 + 1, assert(good(Z1_t));
        member([Temp1, Y], Vis) -> good(Z1), retract(good(Z1)), Z1_t is Z1 + 1, assert(good(Z1_t)); 
        1 = 1
    ),
    (
        Temp2 == Max_x -> good(Z2), retract(good(Z2)), Z2_t is Z2 + 1, assert(good(Z2_t));
        member([Temp2, Y], Vis) -> good(Z2), retract(good(Z2)), Z2_t is Z2 + 1, assert(good(Z2_t));
        1 = 1
    ),
    (
        Temp3 == 0 -> good(Z3), retract(good(Z3)), Z3_t is Z3 + 1, assert(good(Z3_t));
        member([X, Temp3], Vis) -> good(Z3), retract(good(Z3)), Z3_t is Z3 + 1, assert(good(Z3_t));
        1 = 1
    ),
    (
        Temp4 == Max_y -> good(Z4), retract(good(Z4)), Z4_t is Z4 + 1, assert(good(Z4_t));
        member([X, Temp4], Vis) -> good(Z4), retract(good(Z4)), Z4_t is Z4 + 1, assert(good(Z4_t));
        1 = 1
    ),
    good(Res), N = Res, retract(good(Res)).


% search :-
%     check_edge,
%     check_outer_edge,
%     break. 

% check_edge :-
%     edge(Edge),
%     assert(new_cell_opened(false)),
%     forall(member([X, Y], Edge), check(X, Y)),

% check(X, Y) :-
%     pos(X, Y, Props),
%     max_x(Max_x), 
%     max_y(Max_y),
%     visited(Vis), 
%     (member(breeze, Props) ->
%         assert(good(0)),
%         Temp1 is X - 1,
%         Temp2 is X + 1,
%         Temp3 is Y - 1,
%         Temp4 is Y + 1,
%         (
%             Temp1 == 0 -> good(Z1), retract(good(Z1)), assert(good(Z1+1));
%             member([Temp1, Y], Vis) -> good(Z1), retract(good(Z1)), assert(good(Z1+1)); 
%             assert(unvisited([Temp1, Y]))
%         ),
%         (
%             Temp2 == 0 -> good(Z2), retract(good(Z2)), assert(good(Z2+1));
%             member([Temp2, Y], Vis) -> good(Z2), retract(good(Z2)), assert(good(Z2+1));
%             assert(unvisited([Temp1, Y]))
%         ),
%         (
%             Temp3 == 0 -> good(Z3), retract(good(Z3)), assert(good(Z3+1));
%             member([X, Temp3], Vis) -> good(Z3), retract(good(Z3)), assert(good(Z3+1));
%             assert(unvisited([Temp1, Y]))
%         ),
%         (
%             Temp4 == 0 -> good(Z4), retract(good(Z4)), assert(good(Z4+1));
%             member([X, Temp4], Vis) -> good(Z4), retract(good(Z4)), assert(good(Z4+1));
%             assert(unvisited([Temp1, Y]))
%         ),
%         good(Res), retract(good(Res)),
%         (
%             Res == 3 -> 
%         )
%     )
%     ; member(stench, Props) ->
%     ; member(pit, Props) ->
%     ; member(wumpus, Props) ->
%     ).
