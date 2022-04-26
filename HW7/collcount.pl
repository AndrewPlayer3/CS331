% Filename: collcount.pl
% Author:   Andrew Player
% Year:     2022 

% Queries if C is the stopping time for
% N in the Collatz Conjecture
collcount(N, C) :- 
(
    N =:= 1 -> 
        C =:= 0 
        ; 
        (N mod 2 =:= 0 -> 
            collcount(N div 2, C - 1) 
            ; 
            collcount(3 * N + 1, C - 1)
        )
).