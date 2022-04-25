-- Andrew Player
-- March 29, 2022
-- median.hs
-- Program for Assignment 5.C

module Main where

import Data.List 
import System.IO

getNumbers :: IO [Int]
getNumbers = 
    do
        putStr ("Enter number (blank line to end): ")
        hFlush stdout
        inputNumber  <- getLine
        if inputNumber == "" then
            do
                putStrLn ""
                return []
        else
            do
                let number = read inputNumber
                next <- getNumbers
                return (number:next)

doOver :: IO [a]
doOver = 
    do
        putStr "Compute another median? [y/n] "
        hFlush stdout
        choice <- getLine
        putStrLn ""
        if choice == "y" then
            do
                main
        else if choice == "n" then
            do
                putStrLn "Bye!\n"
                return []
        else
            do
                putStrLn "Invalid Choice. Try again.\n"
                doOver

main :: IO [a]
main = 
    do  
        putStrLn "Enter a list of integers, one on each line.\nI will compute the median of the list.\n"  
        hFlush stdout
        inputList <- getNumbers 
        if inputList == [] then
            do
                putStrLn "Empty list - no median\n"
                doOver
        else
            do 
                let sortedInputList = (sort inputList)
                let median = sortedInputList !! (length sortedInputList `div` 2)
                putStr $ "Median: " ++ (show median)
                putStrLn "\n"
                doOver