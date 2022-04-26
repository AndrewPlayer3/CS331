( File:   collcount.fs                )
( Author: Andrew Player, 2022         )
(                                     )
( Counts the stopping time for the    )
( Collatz Conjecture for a given num. )


( Words for Odd Case )

: ifoddadd 1 + ;
: ifodddiv 3 * ;
: ifodd 
    ifodddiv 
    ifoddadd ;


( Word for Even Case )

: ifeven 2 / ;


( Collatz Operation )

: coll dup 
    1 = 
        if
        else 
            dup 
            2 mod 0 = 
                if  
                    ifeven 
                else 
                    ifodd 
                then 
                    swap 1 + swap 
        then ;


( Collatz Loop )

: collcount 
    0 swap 
    begin 
        dup 
        1 > 
        while 
            coll 
        repeat 
            drop . ;