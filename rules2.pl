:- ensure_loaded('map.pl').
:- dynamic queue/1.
:- dynamic visited/1.
:- dynamic edge/1.
:- dynamic pits/1.
:- dynamic wumpus/1.
:- dynamic good/1.
:- dynamic gold/1.

queue([[1, 1]]).
visited([]).
edge([]).
pits([]).
wumpus(unknown).
gold(unknown).

start :-
    queue(Arr),
    (Arr \== [] ->
        queue([[X, Y]|Rest]),
        format('Came to cell (~w, ~w).\n', [X, Y]),
        retract(queue([[X, Y]|Rest])), assert(queue(Rest)),
        retract(visited(Vis)), assert(visited([[X, Y]|Vis])),
        pos(X, Y, Props),
        (member(free, Props) -> 
            write("Oh, it's safe, no breeze or stench here.\n"),
            add_ok_cells(X, Y)
        ;member(gold, Props) ->
            write("Oh, there's gold. Hurray!!!\n"),
            retract(gold(_)), assert(gold([X, Y])),
            gold_found
        ;
            write("Oh, it has breeze or stench.\n"),
            edge(Edge), retract(edge(Edge)), assert(edge([[X, Y]|Edge]))
        )
    ;
        (
            edge(Edge), Edge \== [] -> write("No safe cells, let's try luck.\n"), try_luck
            ; wumpus(Wumpus),
            ( Wumpus == unknown -> write('The map is impossible to solve'), break
                ; wumpus([X|Y]), retract(pos(X, Y, Some)), delete(Some, wumpus, Res), assert(pos(X, Y, Res)),
                retract(edge(_)), assert(edge([[X, Y]]))
            )
        )
    ),
    start. 


gold_found :-
    visited(Vis),
    wumpus(Wumpus),
    gold(Gold),
    pits(Pits),
    format("\n\nResults\nSafe cells: ~w\nGold position: ~w\nWumpus position: ~w\nPits: ~w\n ", [Vis, Gold, Wumpus, Pits]),
    halt.

add_ok_cells(X, Y) :-
    max_x(Max_x), 
    max_y(Max_y),
    visited(Vis), 
    (
        Temp1 is X - 1, Temp1 \== 0, \+ member([Temp1, Y], Vis) -> 
        queue(Arr1), retract(queue(Arr1)), assert(queue([[Temp1, Y]|Arr1])),
        format("New safe cell (~w, ~w).\n", [Temp1, Y]);
        1 = 1
    ),
    (
        Temp2 is X + 1, Temp2 \== Max_x, \+ member([Temp2, Y], Vis) ->
        queue(Arr2), retract(queue(Arr2)), assert(queue([[Temp2, Y]|Arr2])),
        format("New safe cell (~w, ~w).\n", [Temp2, Y]);
        1 = 1
    ),
    (
        Temp3 is Y - 1, Temp3 \== 0, \+ member([X, Temp3], Vis) ->
        queue(Arr3), retract(queue(Arr3)), assert(queue([[X, Temp3]|Arr3])), 
        format("New safe cell (~w, ~w).\n", [X, Temp3]);
        1 = 1
    ),
    (
        Temp4 is Y + 1, Temp4 \== Max_y, \+ member([X, Temp4], Vis) ->
        queue(Arr4), retract(queue(Arr4)), assert(queue([[X, Temp4]|Arr4])),
        format("New safe cell (~w, ~w).\n", [X, Temp4]);
        1 = 1
    ).
   
try_luck :-
    edge([[X, Y]|Res]),
    visited(Vis),
    adj(X, Y, N), 
    Temp1 is X + 1,
    Temp2 is Y + 1,
    Temp3 is X - 1,
    Temp4 is Y - 1,
    (
        \+ member([Temp1, Y], Vis) ->
            (pos(Temp1, Y, Props), 
                (member(free, Props) ->
                    format("I'm so lucky! Cell (~w, ~w) is safe, no breeze or stench in !\n", [Temp1, Y]),
                    add_ok_cells(Temp1, Y)
                ; member(pit, Props) ->
                    format("Oh, i'm unlucky! Cell (~w, ~w) is pit!\n", [Temp1, Y]),
                    format("Memorized pit's location\n"),
                    pits(Pits), retract(pits(Pits)), assert(pits([Temp1, Y|Pits]))
                ; member(wumpus, Props) ->
                    format("Oh, i'm unlucky! Wumpus is sitting in cell (~w, ~w)!\n", [Temp1, Y]),
                    format("Memorized wumpus's location\n"),
                    retract(wumpus(unknown)), assert(wumpus([Temp1, Y]))
                ; member(gold, Props) ->
                    format("Oh, i'm so lucky! Gold is in (~w, ~w) cell!\n", [Temp1, Y]),
                    retract(gold(_)), assert(gold([X, Y])),
                    gold_found
                ;
                    1 = 1
                )),
            (N == 2, \+ member(pit, Props), \+ member(wumpus, Props) ->
                edge(Edge), retract(edge(Edge)), assert(edge([[Temp1, Y]|Edge]))
            ; N == 3, \+ member(pit, Props), \+ member(wumpus, Props) ->
                append(Res, [[Temp1, Y]], Temp), retract(edge(_)), assert(edge(Temp))
            ;
                append(Res, [[X, Y]], Temp),
                retract(edge(_)), assert(edge(Temp))
            )
        ;\+ member([X, Temp2], Vis) ->
            (pos(X, Temp2, Props), 
            (member(free, Props) ->
                format("I'm so lucky! Cell (~w, ~w) is safe, no breeze or stench in!\n", [X, Temp2]),
                add_ok_cells(X, Temp2)
            ; member(pit, Props) ->
                format("Oh, i'm unlucky! Cell (~w, ~w) is pit!\n", [X, Temp2]),
                format("Memorized pit's location\n"),
                pits(Pits), retract(pits(Pits)), assert(pits([X, Temp2|Pits]))
            ; member(wumpus, Props) ->
                format("Oh, i'm unlucky! Wumpus is sitting in cell (~w, ~w)!\n", [X, Temp2]),
                format("Memorized wumpus's location\n"),
                retract(wumpus(unknown)), assert(wumpus([X, Temp2]))
            ; member(gold, Props) ->
                format("Oh, i'm so lucky! Gold is in (~w, ~w) cell!\n", [X, Temp2]),
                retract(gold(_)), assert(gold([X, Y])),
                gold_found
            ;
                retract(edge(_)), assert(edge(Res))
            )),
            (N == 2, \+ member(pit, Props), \+ member(wumpus, Props) ->
                edge(Edge), retract(edge(Edge)), assert(edge([[X, Temp2]|Edge]))
            ; N == 3, \+ member(pit, Props), \+ member(wumpus, Props) ->
                append(Res, [[X, Temp2]], Temp), retract(edge(_)), assert(edge(Temp))
            ;
                % retract(edge(_)), assert(edge(Res))
                1 = 1
            )
        ;\+ member([Temp3, Y], Vis) ->
            (pos(Temp3, Y, Props), 
            (member(free, Props) ->
                format("I'm so lucky! Cell (~w, ~w) is safe, no breeze or stench in!\n", [Temp3, Y]),
                add_ok_cells(Temp3, Y)
            ; member(pit, Props) ->
                format("Oh, i'm unlucky! Cell (~w, ~w) is pit!\n", [Temp3, Y]),
                format("Memorized pit's location\n"),
                pits(Pits), retract(pits(Pits)), assert(pits([Temp3, Y|Pits]))
            ; member(wumpus, Props) ->
                format("Oh, i'm unlucky! Wumpus is sitting in cell (~w, ~w)!\n", [Temp3, Y]),
                format("Memorized wumpus's location\n"),
                retract(wumpus(unknown)), assert(wumpus([Temp3, Y]))
            ; member(gold, Props) ->
                format("Oh, i'm so lucky! Gold is in (~w, ~w) cell!\n", [Temp3, Y]),
                retract(gold(_)), assert(gold([X, Y])),
                gold_found
            ;
                1 = 1
            )),
            (N == 2, \+ member(pit, Props), \+ member(wumpus, Props) ->
                edge(Edge), retract(edge(Edge)), assert(edge([[Temp3, Y]|Edge]))
            ; N == 3, \+ member(pit, Props), \+ member(wumpus, Props) ->
                append(Res, [[Temp3, Y]], Temp), retract(edge(_)), assert(edge(Temp))
            ;
                %  retract(edge(_)), assert(edge(Res))
                1 = 1
            )
        ;\+ member([X, Temp4], Vis) ->
            (pos(X, Temp4, Props), 
            (member(free, Props) ->
                format("I'm so lucky! Cell (~w, ~w) is safe, no breeze or stench in!\n", [X, Temp4]),
                add_ok_cells(X, Temp4)
            ; member(pit, Props) ->
                format("Oh, i'm unlucky! Cell (~w, ~w) is pit!\n", [X, Temp4]),
                format("Memorized pit's location\n"),
                pits(Pits), retract(pits(Pits)), assert(pits([X, Temp4|Pits]))
            ; member(wumpus, Props) ->
                format("Oh, i'm unlucky! Wumpus is sitting in cell (~w, ~w)!\n", [X, Temp4]),
                format("Memorized wumpus's location\n"),
                retract(wumpus(unknown)), assert(wumpus(X, Temp4))
            ; member(gold, Props) ->
                format("Oh, i'm so lucky! Gold is in (~w, ~w) cell!\n", [X, Temp4]),
                retract(gold(_)), assert(gold([X, Y])),
                gold_found
            ;
                1 = 1
            )),
            (N == 2, \+ member(pit, Props), \+ member(wumpus, Props) ->
                edge(Edge), retract(edge(Edge)), assert(edge([[X, Temp4]|Edge]))
            ; N == 3, \+ member(pit, Props), \+ member(wumpus, Props) ->
                append(Res, [[X, Temp4]], Temp), retract(edge(_)), assert(edge(Temp))
            ; 
                % retract(edge(_)), assert(edge(Res))
                1 = 1
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
