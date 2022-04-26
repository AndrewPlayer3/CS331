( File:   collcount.fs                )
( Author: Andrew Player, 2022         )
( ----------------------------------- )
( Counts the stopping time for the    )
( Collatz Conjecture for a given num. )

( Collatz Operation )
( ----------------- )
: coll 
    dup 
    1 = 
        if
        else 
            dup 
            2 mod 0 = 
                if  
                    2 / 
                else 
                    3 * 1 + 
                then 
                    swap 1 + swap 
        then ;

( Collatz Loop )
( ------------ )
: collcount 
    0 swap 
    begin 
        dup 
        1 > 
        while 
            coll 
        repeat 
            drop ;