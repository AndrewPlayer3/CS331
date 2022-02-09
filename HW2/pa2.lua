-- Created By: Andrew Player
-- Last Revision Date: Feb 8, 2022
-- Description: lua module for homework #2


-- maps the values in table t with function f
local mapTable = function(f, t)
    local newTable = {}
    for key, value in pairs(t) do
        value = f(value)
        newTable[key] = value
    end

    return newTable 
end


-- Concatinate str to itself until its length is greater than int
-- returns "" if the length is greater than int at the start
local concatMax = function(str, int)
    local newStr = ""
    while string.len(newStr .. str) <= int do
        newStr = newStr .. str
    end
    return newStr
end


-- Factory for collatz sequence iterator
local collatz = function(n)
    local currentValue = n
    return function()
        if currentValue == 1 then
            currentValue = 0
            return 1
        elseif currentValue > 1 then
            local temp = currentValue
            if currentValue % 2 == 0 then
                currentValue = math.floor(currentValue / 2)
            else
                currentValue = 3 * currentValue + 1
            end
            return temp
        end
    end
end


-- Return the substrings of the reverse of s
local backSubs = function(s)
    coroutine.yield("")
    s = string.reverse(s)
    local sLen = string.len(s)
    for inc=0, sLen - 1,1 do 
        for i=1, sLen - inc, 1 do
            local c = s:sub(i, i+inc)
            if c then
                coroutine.yield(c)
            end
        end
    end
end


-- Return the pa2 functions
local pa2 = {
    mapTable = mapTable,
    concatMax = concatMax,
    collatz = collatz,
    backSubs = backSubs
}

return pa2
