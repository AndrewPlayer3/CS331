-- Andrew Player 
-- 2022-03-28
--
-- For CS F331 / CSCE A331 Spring 2022
-- Solutions to Assignment 5 Exercise B

module PA5 where


-- =====================================================================


-- collatzCounts
collatzCounts :: [Integer]
collatzCounts =
    map counter [1..] where
        counter n
            | n == 1    = 0
            | even n    = 1 + counter (div n   2)
            | otherwise = 1 + counter (3 * n + 1)



-- =====================================================================


-- findList
findList :: Eq a => [a] -> [a] -> Maybe Int
findList [] _ = Just 0
findList as  bs = 
    let n = 0 in match as bs n where
        match as bs n 
            | take (length as) bs == as = Just n
            | length as > length bs     = Nothing
            | otherwise                 = match as (tail bs) (n + 1)  


-- =====================================================================


-- operator ##
(##) :: Eq a => [a] -> [a] -> Int
_  ## [] = 0
[] ##  _ = 0
as ## bs = 
    length [x | x <- (zipWith (==) as bs), x == True]


-- =====================================================================


-- filterAB
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB _ _ []  = []
filterAB _ [] _  = []
filterAB n as bs = 
    map snd (filter ((== True) . fst) (zip (map n as) bs))


-- =====================================================================


-- sumEvenOdd
{-
  The assignment requires sumEvenOdd to be written as a fold.
  Like this:

    sumEvenOdd xs = fold* ... xs  where
        ...

  Above, "..." should be replaced by other code. "fold*" must be one of
  the following: foldl, foldr, foldl1, foldr1.
-}
sumEvenOdd :: Num a => [a] -> (a, a)
sumEvenOdd xs =
    (foldr (+) 0 evens, foldr (+) 0 odds) where
        evens = map fst (filter (even . snd) (zip xs [0..]))
        odds  = map fst (filter (odd  . snd) (zip xs [0..]))
 

