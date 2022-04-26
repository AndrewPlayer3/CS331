local interpit = require("interpit")
local parseit = require("parseit")

input = {"37"}

local incount = 0
local function incall(param)
    if param ~= nil then
         print("ERROR INCALL PARAM")
    end
    incount = incount + 1
    if incount <= #input then
        return input[incount]
    else
        return ""
    end
end

-- numKeys
-- Given a table, return the number of keys in it.
function numKeys(tab)
    local keycount = 0
    for k, v in pairs(tab) do
        keycount = keycount + 1
    end
    return keycount
end


-- equal
-- Compare equality of two values. Returns false if types are different.
-- Uses "==" on non-table values. For tables, recurses for the value
-- associated with each key.
function equal(...)
    assert(select("#", ...) == 2,
           "equal: must pass exactly 2 arguments")
    local x1, x2 = select(1, ...)  -- Get args (may be nil)

    local type1 = type(x1)
    if type1 ~= type(x2) then
        return false
    end

    if type1 ~= "table" then
       return x1 == x2
    end

    -- Get number of keys in x1 & check values in x1, x2 are equal
    local x1numkeys = 0
    for k, v in pairs(x1) do
        x1numkeys = x1numkeys + 1
        if not equal(v, x2[k]) then
            return false
        end
    end

    -- Check number of keys in x1, x2 same
    local x2numkeys = 0
    for k, v in pairs(x2) do
        x2numkeys = x2numkeys + 1
    end
    return x1numkeys == x2numkeys
end

function isState(tab)
    -- Is table?
    if type(tab) ~= "table" then
        print("not table")
        return false
    end

    -- Has exactly 3 keys?
    if numKeys(tab) ~= 3 then
        print("bad num keys")
        return false
    end

    -- Has f, v, a keys?
    if tab.f == nil or tab.v == nil or tab.a == nil then
        print("not correct keys")
        return false
    end

    -- f, v, a keys are tables?
    if type(tab.f) ~= "table"
      or type(tab.v) ~= "table"
      or type(tab.a) ~= "table" then
        print("keys not tables")
        return false
    end

    -- All items in f are string:table
    -- String begins with "[_A-Za-z]"
    for k, v in pairs(tab.f) do
        if type(k) ~= "string" or type(v) ~= "table" then
            print("f items not string:table")
            return false
        end
        if k:sub(1,1) ~= "_"
           and (k:sub(1,1) < "A" or k:sub(1,1) > "Z")
           and (k:sub(1,1) < "a" or k:sub(1,1) > "z") then
            print("f items not string:table 2")
            return false
        end
    end

    -- All items in v are string:number
    -- String begins with "[_A-Za-z]"
    for k, v in pairs(tab.v) do
        if type(k) ~= "string" or type(v) ~= "number" then
            print("v items not string:number")
            print(type(k))
            print(type(v))
            return false
        end
        if k:sub(1,1) ~= "_"
           and (k:sub(1,1) < "A" or k:sub(1,1) > "Z")
           and (k:sub(1,1) < "a" or k:sub(1,1) > "z") then
            print("v items not string:number 2")
            return false
        end
    end

    -- All items in a are string:table
    -- String begins with "[_A-Za-z]"
    -- All items in values in a are number:number
    for k, v in pairs(tab.a) do
        if type(k) ~= "string" or type(v) ~= "table" then
            print("a items not string:table")
            return false
        end
        if k:sub(1,1) ~= "_"
           and (k:sub(1,1) < "A" or k:sub(1,1) > "Z")
           and (k:sub(1,1) < "a" or k:sub(1,1) > "z") then
            print("a items are not string:table 2")
            return false
        end
        for kk, vv in pairs(v) do
            if type(kk) ~= "number" or type(vv) ~= "number" then
                print("a items values are not number:number")
                return false
            end
        end
    end

    return true
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end


-- local prog = "if (1 == 1) { print(\"if parsed\"); } elif (2 == 2){ print(\"elif 1 parsed\"); } else { print(\"else parsed\"); }"
-- local prog = "if ( 1 == 1 ) { a = 123; }"
-- local prog = "a = 0; while (a < 10) { print(a); a = a + 1; }"
-- local prog = "a = 3; a = a + 10;"
-- local prog = "123"
-- local prog = "while(0) {};"
local prog = "print(char(asdsad));"


local expstateout = {v={["b"]=37}, a={}, f={}}


-- local state = { v={}, a={}, f={} }
-- local incall = io.read

local state = {v={["a"]=1,["b"]=2}, a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}

local outcall = print

-- local ast = {STMT_LIST, {ASSN_STMT, {SIMPLE_VAR, "b"},
--       {READ_CALL}}}

local good, _, ast = parseit.parse(prog)
if not good then
    print("Prog not good.")
else
    interpit.interp(ast, state, incall, outcall)
end


print("\nState:")
print(dump(state))
print()
print("Expected State:")
print(dump(expstateout))
print(isState(state))
print(isState(expstateout))