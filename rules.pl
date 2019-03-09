:- ensure_loaded('map.pl').

die(X, Y) :-
    pos(X, Y, Cell), Cell \== free, Cell \== gold, Cell \== hero.

start :-
    main(1, 1).
    
main(X, Y) :-
    pos(X, Y, K), 
    assert(visited(X, Y)),
    (member(M, K) == free ->
        make_ok(X, Y)
    ;
        check(X, Y)
    ).
     
make_ok(X, Y) :-
    max_x(Max_x), 
    max_y(Max_y),
    (
        Temp is X - 1, Temp \== 0, \+ ok(Temp, Y), assert(ok(Temp, Y));
        Temp is X + 1, Temp \== Max_x, \+ ok(Temp, Y), assert(ok(Temp, Y));
        Temp is Y - 1, Temp \== 0, \+ ok(X, Temp), assert(ok(X, Temp)); 
        Temp is Y + 1, Temp \== Max_y, \+ ok(X, Temp), assert(ok(X, Temp))
    ).    

check(X, Y) :-
    1 == 1.