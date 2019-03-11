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
            ( Wumpus == unknown -> write("The map is impossible to solve"), break
                ; wumpus([X,Y|_]), retract(pos(X, Y, Some)), delete(Some, wumpus, Res), assert(pos(X, Y, Res)),
                retract(queue(_)), assert(queue([[X, Y]])), retract(wumpus(_)), assert(wumpus(unknown)),
                write("Wumpus has been killed!\n")
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
        Temp1 is X - 1, Temp1 =< Max_x, Temp1 > 0, \+ member([Temp1, Y], Vis) -> 
        queue(Arr1), retract(queue(Arr1)), assert(queue([[Temp1, Y]|Arr1])),
        format("New safe cell (~w, ~w).\n", [Temp1, Y]);
        1 = 1
    ),
    (
        Temp2 is X + 1, Temp2 > 0, Temp2 =< Max_x, \+ member([Temp2, Y], Vis) ->
        queue(Arr2), retract(queue(Arr2)), assert(queue([[Temp2, Y]|Arr2])),
        format("New safe cell (~w, ~w).\n", [Temp2, Y]);
        1 = 1
    ),
    (
        Temp3 is Y - 1, Temp3 =< Max_y, Temp3 > 0, \+ member([X, Temp3], Vis) ->
        queue(Arr3), retract(queue(Arr3)), assert(queue([[X, Temp3]|Arr3])), 
        format("New safe cell (~w, ~w).\n", [X, Temp3]);
        1 = 1
    ),
    (
        Temp4 is Y + 1, Temp4 > 0, Temp4 =< Max_y, \+ member([X, Temp4], Vis) ->
        queue(Arr4), retract(queue(Arr4)), assert(queue([[X, Temp4]|Arr4])),
        format("New safe cell (~w, ~w).\n", [X, Temp4]);
        1 = 1
    ).
   
try_luck :-
    max_x(Max_x),
    max_y(Max_y),
    edge([[X, Y]|Res]),
    visited(Vis),
    adj(X, Y, N), 
    wumpus(Wumpus),
    pits(Pits),
    Temp1 is X + 1,
    Temp2 is Y + 1,
    Temp3 is X - 1,
    Temp4 is Y - 1,
    (
        \+ member([Temp1, Y], Vis), Wumpus \== [Temp1, Y], \+ member([Temp1, Y], Pits), Temp1 > 0, Temp1 =< Max_x  ->
            format("Came into cell (~w, ~w).\n", [Temp1, Y]),
            (pos(Temp1, Y, Props), 
                (member(free, Props) ->
                    format("I'm so lucky! Cell (~w, ~w) is safe, no breeze or stench in !\n", [Temp1, Y]),
                    add_ok_cells(Temp1, Y)
                ; member(pit, Props) ->
                    format("Oh, i'm unlucky! Cell (~w, ~w) is pit!\n", [Temp1, Y]),
                    format("Memorized pit's location\n"),
                    pits(Pits), retract(pits(Pits)), assert(pits([[Temp1, Y]|Pits]))
                ; member(wumpus, Props) ->
                    format("Oh, i'm unlucky! Wumpus is sitting in cell (~w, ~w)!\n", [Temp1, Y]),
                    format("Memorized wumpus's location\n"),
                    retract(wumpus(unknown)), assert(wumpus([Temp1, Y]))
                ; member(gold, Props) ->
                    format("Oh, i'm so lucky! Gold is in (~w, ~w) cell!\n", [Temp1, Y]),
                    retract(gold(_)), assert(gold([Temp1, Y])),
                    gold_found
                ;
                    write("Oh, it has breeze or stench.\n"),
                    retract(visited(Vis)), assert(visited([[Temp1, Y]|Vis]))
                )),
            (N == 2, \+ member(pit, Props), \+ member(wumpus, Props) ->
                edge(Edge), retract(edge(Edge)), assert(edge([[Temp1, Y]|Edge]))
            ; N == 3, \+ member(pit, Props), \+ member(wumpus, Props) ->
                append(Res, [[Temp1, Y]], Temp), retract(edge(_)), assert(edge(Temp))
            ; N >= 3 ->
                edge(Edge), retract(edge(Edge)), assert(edge(Res))
            ;
                append(Res, [[X, Y]], Temp),
                retract(edge(_)), assert(edge(Temp))
            )
        ;\+ member([X, Temp2], Vis), Wumpus \== [X, Temp2], \+ member([X, Temp2], Pits), Temp2 > 0, Temp2 =< Max_y ->
            format("Came into cell (~w, ~w).\n", [X, Temp2]),
            (pos(X, Temp2, Props), 
            (member(free, Props) ->
                format("I'm so lucky! Cell (~w, ~w) is safe, no breeze or stench in!\n", [X, Temp2]),
                add_ok_cells(X, Temp2)
            ; member(pit, Props) ->
                format("Oh, i'm unlucky! Cell (~w, ~w) is pit!\n", [X, Temp2]),
                format("Memorized pit's location\n"),
                pits(Pits), retract(pits(Pits)), assert(pits([[X, Temp2]|Pits]))
            ; member(wumpus, Props) ->
                format("Oh, i'm unlucky! Wumpus is sitting in cell (~w, ~w)!\n", [X, Temp2]),
                format("Memorized wumpus's location\n"),
                retract(wumpus(unknown)), assert(wumpus([X, Temp2]))
            ; member(gold, Props) ->
                format("Oh, i'm so lucky! Gold is in (~w, ~w) cell!\n", [X, Temp2]),
                retract(gold(_)), assert(gold([X, Temp2])),
                gold_found
            ;
                retract(visited(Vis)), assert(visited([[X, Temp2]|Vis]))
            )),
            (N == 2, \+ member(pit, Props), \+ member(wumpus, Props) ->
                edge(Edge), retract(edge(Edge)), assert(edge([[X, Temp2]|Edge]))
            ; N == 3, \+ member(pit, Props), \+ member(wumpus, Props) ->
                append(Res, [[X, Temp2]], Temp), retract(edge(_)), assert(edge(Temp))
            ; N >= 3 ->
                edge(Edge), retract(edge(Edge)), assert(edge(Res))
            ;
                append(Res, [[X, Y]], Temp),
                retract(edge(_)), assert(edge(Temp))
            )
        ;\+ member([Temp3, Y], Vis), Wumpus \== [Temp3, Y], \+ member([Temp3, Y], Pits), Temp3 > 0, Temp3 =< Max_x ->
            format("Came into cell (~w, ~w).\n", [Temp3, Y]),
            (pos(Temp3, Y, Props), 
            (member(free, Props) ->
                format("I'm so lucky! Cell (~w, ~w) is safe, no breeze or stench in!\n", [Temp3, Y]),
                add_ok_cells(Temp3, Y)
            ; member(pit, Props) ->
                format("Oh, i'm unlucky! Cell (~w, ~w) is pit!\n", [Temp3, Y]),
                format("Memorized pit's location\n"),
                pits(Pits), retract(pits(Pits)), assert(pits([[Temp3, Y]|Pits]))
            ; member(wumpus, Props) ->
                format("Oh, i'm unlucky! Wumpus is sitting in cell (~w, ~w)!\n", [Temp3, Y]),
                format("Memorized wumpus's location\n"),
                retract(wumpus(unknown)), assert(wumpus([Temp3, Y]))
            ; member(gold, Props) ->
                format("Oh, i'm so lucky! Gold is in (~w, ~w) cell!\n", [Temp3, Y]),
                retract(gold(_)), assert(gold([Temp3, Y])),
                gold_found
            ;
                retract(visited(Vis)), assert(visited([[Temp3, Y]|Vis]))
            )),
            (N == 2, \+ member(pit, Props), \+ member(wumpus, Props) ->
                edge(Edge), retract(edge(Edge)), assert(edge([[Temp3, Y]|Edge]))
            ; N == 3, \+ member(pit, Props), \+ member(wumpus, Props) ->
                append(Res, [[Temp3, Y]], Temp), retract(edge(_)), assert(edge(Temp))
            ; N >= 3 ->
                edge(Edge), retract(edge(Edge)), assert(edge(Res))
            ;
                append(Res, [[X, Y]], Temp),
                retract(edge(_)), assert(edge(Temp))  
            )
        ;\+ member([X, Temp4], Vis), Wumpus \== [X, Temp4], \+ member([X, Temp4], Pits), Temp4 > 0, Temp4 =< Max_y ->
            format("Came into cell (~w, ~w).\n", [X, Temp4]),
            (pos(X, Temp4, Props), 
            (member(free, Props) ->
                format("I'm so lucky! Cell (~w, ~w) is safe, no breeze or stench in!\n", [X, Temp4]),
                add_ok_cells(X, Temp4)
            ; member(pit, Props) ->
                format("Oh, i'm unlucky! Cell (~w, ~w) is pit!\n", [X, Temp4]),
                format("Memorized pit's location\n"),
                pits(Pits), retract(pits(Pits)), assert(pits([[X, Temp4]|Pits]))
            ; member(wumpus, Props) ->
                format("Oh, i'm unlucky! Wumpus is sitting in cell (~w, ~w)!\n", [X, Temp4]),
                format("Memorized wumpus's location\n"),
                retract(wumpus(unknown)), assert(wumpus(X, Temp4))
            ; member(gold, Props) ->
                format("Oh, i'm so lucky! Gold is in (~w, ~w) cell!\n", [X, Temp4]),
                retract(gold(_)), assert(gold([X, Temp4])),
                gold_found
            ;
                retract(visited(Vis)), assert(visited([[X, Temp4]|Vis]))
            )),
            (N == 2, \+ member(pit, Props), \+ member(wumpus, Props) ->
                edge(Edge), retract(edge(Edge)), assert(edge([[X, Temp4]|Edge]))
            ; N == 3, \+ member(pit, Props), \+ member(wumpus, Props) ->
                append(Res, [[X, Temp4]], Temp), retract(edge(_)), assert(edge(Temp))
            ; N >= 3 ->
                edge(Edge), retract(edge(Edge)), assert(edge(Res))
            ;
                append(Res, [[X, Y]], Temp),
                retract(edge(_)), assert(edge(Temp)) 
            )
        ;
            retract(edge(_)), assert(edge(Res))
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
        Temp2 is Max_x + 1 -> good(Z2), retract(good(Z2)), Z2_t is Z2 + 1, assert(good(Z2_t));
        member([Temp2, Y], Vis) -> good(Z2), retract(good(Z2)), Z2_t is Z2 + 1, assert(good(Z2_t));
        1 = 1
    ),
    (
        Temp3 == 0 -> good(Z3), retract(good(Z3)), Z3_t is Z3 + 1, assert(good(Z3_t));
        member([X, Temp3], Vis) -> good(Z3), retract(good(Z3)), Z3_t is Z3 + 1, assert(good(Z3_t));
        1 = 1
    ),
    (
        Temp4 is Max_y + 1 -> good(Z4), retract(good(Z4)), Z4_t is Z4 + 1, assert(good(Z4_t));
        member([X, Temp4], Vis) -> good(Z4), retract(good(Z4)), Z4_t is Z4 + 1, assert(good(Z4_t));
        1 = 1
    ),
    good(Res), N = Res, retract(good(Res)).
