# AI Wumpus World

Run the program:
  ```prolog rules.pl```
  
You can choose different maps by changing first row in rules.pl file

``` 
%  file rules.pl
:- ensure_loaded('kill_wumpus_map.pl'). <------
:- dynamic queue/1.
:- dynamic visited/1.
:- dynamic edge/1.
:- dynamic pits/1.
```
## Available Maps
* map.pl
* map2.pl
* impossible_map.pl
* kill_wumpus_map.pl
