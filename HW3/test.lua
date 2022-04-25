lexit = require "lexit"
parseit = require "parseit"

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

symbolNames = {
    [1]="STMT_LIST",
    [2]="PRINT_STMT",
    [3]="RETURN_STMT",
    [4]="ASSN_STMT",
    [5]="FUNC_CALL",
    [6]="FUNC_DEF",
    [7]="IF_STMT",
    [8]="WHILE_LOOP",
    [9]="STRLIT_OUT",
    [10]="CR_OUT",
    [11]="CHAR_CALL",
    [12]="BIN_OP",
    [13]="UN_OP",
    [14]="NUMLIT_VAL",
    [15]="BOOLLIT_VAL",
    [16]="READ_CALL",
    [17]="SIMPLE_VAR",
    [18]="ARRAY_VAR",
  }
  

function printAST_parseit(...)
    if select("#", ...) ~= 1 then
        error("printAST_parseit: must pass exactly 1 argument")
    end
    local x = select(1, ...)  -- Get argument (which may be nil)

    if type(x) == "nil" then
        io.write("nil")
    elseif type(x) == "number" then
        if symbolNames[x] then
            io.write(symbolNames[x])
        else
            io.write("<ERROR: Unknown constant: "..x..">")
        end
    elseif type(x) == "string" then
        io.write('"'..x..'"')
    elseif type(x) == "boolean" then
        if x then
            io.write("true")
        else
            io.write("false")
        end
    elseif type(x) ~= "table" then
        io.write('<'..type(x)..'>')
    else  -- type is "table"
        io.write("{ ")
        local first = true  -- First iteration of loop?
        local maxk = 0
        for k, v in ipairs(x) do
            if first then
                first = false
            else
                io.write(", ")
            end
            maxk = k
            printAST_parseit(v)
        end
        for k, v in pairs(x) do
            if type(k) ~= "number"
              or k ~= math.floor(k)
              or (k < 1 and k > maxk) then
                if first then
                    first = false
                else
                    io.write(", ")
                end
                io.write("[")
                printAST_parseit(k)
                io.write("]=")
                printAST_parseit(v)
            end
        end
        io.write(" }")
    end
end

STR = "12#a\n#b\n#c\nab"

Foo = lexit.lex(STR)

while true do
    local a, b = Foo()
    if a == nil or b == nil then break end
    -- print(a, b)
end

PROG1 = "if (nn) { foo(); nn = bar(); x = read(); } elseif (yy == ss) { print(); } else { y = 73; }"
PROG2 = "while(nn) {print();}"
PROG3 = "print();print();print();"
PROG4 = "x=a[1];"
PROG5 = "if(true){}elif(false){}else{}"

good, done, ast = parseit.parse(PROG4)

print(good, done)
printAST_parseit(ast)
