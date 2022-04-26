-- parseit.lua
-- Andrew Player
--
-- For CS F331 / CSCE A331 Spring 2022
-- Solution to Assignment 4, Exercise 1
-- Requires lexit.lua

local lexit = require "lexit"

local parseit = {}


-------------------------
--> Initial Variables <--
-------------------------

-- For lexer iteration
local iter          -- Iterator from lexit
local state         -- State for the lexit iterator
local lexer_out_s   -- Return value #1 from iterator
local lexer_out_c   -- Return Value #2 from iterator

-- For current lexeme
local lexstr = ""   -- String from current lexeme
local lexcat = 0    -- Category of current lexeme


----------------------------------
--> Symbolic Constants for AST <--
----------------------------------

local STMT_LIST   = 1
local PRINT_STMT  = 2
local RETURN_STMT = 3
local ASSN_STMT   = 4
local FUNC_CALL   = 5
local FUNC_DEF    = 6
local IF_STMT     = 7
local WHILE_LOOP  = 8
local STRLIT_OUT  = 9
local CR_OUT      = 10
local CHAR_CALL   = 11
local BIN_OP      = 12
local UN_OP       = 13
local NUMLIT_VAL  = 14
local BOOLLIT_VAL = 15
local READ_CALL   = 16
local SIMPLE_VAR  = 17
local ARRAY_VAR   = 18


-------------------------
--> Utility Functions <--
-------------------------

-- Advance the lexit iterator
local function advance()
    
    lexer_out_s, lexer_out_c = iter(state, lexer_out_s)

    if lexer_out_s ~= nil then
        lexstr, lexcat = lexer_out_s, lexer_out_c
    else
        lexstr, lexcat = "", 0
    end
end

-- Get the iterator from lexit for parsing
local function init(prog)
    iter, state, lexer_out_s = lexit.lex(prog)
    advance()
end

-- determines if the end of input has been reached
local function atEnd()
    return lexcat == 0
end

-- matches a string with lexstr
local function matchString(s)
    if lexstr == s then
        advance()
        return true
    else  
        return false
    end
end

-- matches a category with lexcat
local function matchCat(c)
    if lexcat == c then
        advance()
        return true
    else
        return false
    end
end


----------------------------------------------
--> Local statements for parsing functions <--
----------------------------------------------

local parse_program
local parse_stmt_list
local parse_simple_stmt
local parse_complex_stmt
local parse_print_arg
local parse_expr
local parse_compare_expr
local parse_arith_expr
local parse_term
local parse_factor


--------------
--> Parser <--
--------------

function parseit.parse(prog)
    
    init(prog)

    local good, ast = parse_program()
    local done = atEnd()

    return good, done, ast
end


-------------------------
--> Parsing Functions <--
-------------------------

function parse_program()

    local good, ast

    good, ast = parse_stmt_list()

    return good, ast
end


function parse_stmt_list()

    local good, ast1, ast2

    ast1 = { STMT_LIST }
    while true do

        if lexstr == "print"
            or lexstr == "return"
            or lexcat == lexit.ID then

                good, ast2 = parse_simple_stmt()
                if not good then
                    return false, nil
                end

                if not matchString(";") then
                    return false, nil
                end

        elseif lexstr == "func"
            or lexstr == "if"
            or lexstr == "while" then

                good, ast2 = parse_complex_stmt()
                if not good then
                    return false, nil
                end

        else

            break
        end

        table.insert(ast1, ast2)
    end

    -- if table.getn(ast1) == 1 then
    --     return true, nil
    -- end

    return true, ast1
end


function parse_simple_stmt()

    local good, ast1, ast2, savelex, arrayflag

    savelex = lexstr

    if matchString("print") then
        if not matchString("(") then
            return false, nil
        end

        if matchString(")") then
            return true, { PRINT_STMT }
        end

        good, ast1 = parse_print_arg()
        if not good then
            return false, nil
        end

        ast2 = { PRINT_STMT, ast1 }

        while matchString(",") do
            good, ast1 = parse_print_arg()
            if not good then
                return false, nil
            end
            table.insert(ast2, ast1)
        end

        if not matchString(")") then
            return false, nil
        end

        return true, ast2

    elseif matchString("return") then
        
        good, ast1 = parse_expr()

        if not good then
            return false, nil
        end

        return true, { RETURN_STMT, ast1 }
    
    elseif matchCat(lexit.ID) then
        -- TODO: Write this part.

        if matchString("(") then
            if not matchString(")") then
                return false, nil
            end
            return true, { FUNC_CALL, savelex }
        end

        ast2 = { ASSN_STMT }

        if matchString("[") then
            good, ast1 = parse_expr()
            if not good then
                return false, nil
            end
            if not matchString("]") then
                return false, nil
            end
            table.insert(ast2, { ARRAY_VAR, savelex, ast1 })
        else
            table.insert(ast2, { SIMPLE_VAR, savelex })
        end

        if not matchString("=") then
            return false, nil
        end

        good, ast1 = parse_expr()
        if not good then
            return false, nil
        end

        table.insert(ast2, ast1)

        return true, ast2
    end

    return false, nil
end
        

function parse_complex_stmt()
    -- TODO: Write this part
    local good, ast1, ast2, savelex, arrayflag

    if matchString("func") then
        
        savelex = lexstr

        if matchCat(lexit.ID) then

            if not matchString("(") then
                return false, nil
            end

            if not matchString(")") then
                return false, nil
            end

            if not matchString("{") then
                return false, nil
            end

            good, ast1 = parse_stmt_list()
            if not good then
                return false, nil
            end

            if not matchString("}") then
                return false, nil
            end

            return true, { FUNC_DEF, savelex, ast1 }
        end
    elseif matchString("if") then
        
        savelex = lexstr

        good, ast1 = parse_if_stmt()
        if not good then
            return false, nil
        end

        return true, ast1

    elseif matchString("while") then
    
        savelex = lexstr

        good, ast1 = parse_while_stmt()
        if not good then
            return false, nil
        end

        return true, ast1
    end

    return false, nil
end


function parse_while_stmt()
    local good, ast1, ast2, ast3, savelex

    if not matchString("(") then
        return false, nil
    end

    good, ast1 = parse_expr()
    if not good then
        return false, nil
    end

    if not matchString(")") then
        return false, nil
    end

    if not matchString("{") then
        return false, nil
    end

    good, ast2 = parse_stmt_list()
    if not good then
        return false, nil
    end

    if not matchString("}") then
        return false, nil
    end

    return true, { WHILE_LOOP, ast1, ast2 }
end


function parse_if_stmt()

    local good, ast1, ast2, ast3

    good, ast1, ast2 = parse_expr_plus_stmt()
    if not good then
        return false, nil
    end

    ast3 = { IF_STMT }

    table.insert(ast3, ast1)
    table.insert(ast3, ast2)

    while matchString("elif") do
        good, ast1, ast2 = parse_expr_plus_stmt()
        if not good then
            return false, nil
        end
        table.insert(ast3, ast1)
        table.insert(ast3, ast2)
    end

    if matchString("else") then
        if not matchString("{") then
            return false, nil
        end
        good, ast1 = parse_stmt_list()
        if not good then
            return false, nil
        end
        if not matchString("}") then
            return false, nil
        end

        table.insert(ast3, ast1)
    end

    return true, ast3
end


function parse_expr_plus_stmt()
    local good, ast1, ast2
    if not matchString("(") then
        return false, nil
    end
    good, ast1 = parse_expr()
    if not good then
        return false, nil
    end
    if not matchString(")") then
        return false, nil
    end
    if not matchString("{") then
        return false, nil
    end
    good, ast2 = parse_stmt_list()
    if not good then
        return false, nil
    end
    if not matchString("}") then
        return false, nil
    end
    return true, ast1, ast2
end


function parse_print_arg()

    local good, ast1, ast2, savelex, arrayflag

    savelex = lexstr

    if matchCat(lexit.STRLIT) then
        return true, { STRLIT_OUT, savelex }
    end

    if matchString("cr") then
        return true, { CR_OUT }
    end

    if matchString("char") then

        if not matchString("(") then
            return false, nil
        end

        good, ast1 = parse_expr()
        if not good then
            return false, nil
        end

        if not matchString(")") then
            return false, nil
        end

        return true, { CHAR_CALL, ast1 }
    end

    good, ast2 = parse_expr()
    if not good then
        return false, nil
    end

    return true, ast2
end


function parse_expr()

    local good, ast1, ast2, ast3, savelex, arrayflag

    good, ast1 = parse_compare_expr()
    if not good then
        return false, nil
    end

    savelex = lexstr

    while matchString("and") or matchString("or") do
        good, ast2 = parse_compare_expr()
        if not good then
            return false, nil
        end
        ast3 = { { BIN_OP, savelex }, ast1, ast2 }
        ast1 = ast3
        savelex = lexstr
    end

    return true, ast1
end


function parse_compare_expr()

    local good, ast1, ast2, ast3, savelex, arrayflag

    good, ast1 = parse_arith_expr()
    if not good then
        return false, nil
    end

    savelex = lexstr
    while  matchString("==") 
        or matchString("!=") 
        or matchString("<")
        or matchString("<=")
        or matchString(">")
        or matchString(">=") do

        good, ast2 = parse_arith_expr()
        if not good then
            return false, nil
        end

        ast3 = { { BIN_OP, savelex }, ast1, ast2 }
        ast1 = ast3
        savelex = lexstr
    end

    return true, ast1
end


function parse_arith_expr()

    local good, ast1, ast2, ast3, savelex, arrayflag

    good, ast1 = parse_term()
    if not good then
        return false, nil
    end

    savelex = lexstr
    while matchString("+") or matchString("-") do
        good, ast2 = parse_term()
        if not good then
            return false, nil
        end
        ast3 = { { BIN_OP, savelex }, ast1, ast2 }
        ast1 = ast3
        savelex = lexstr
    end

    return true, ast1
end


function parse_term()

    local good, ast1, ast2, ast3, savelex, arrayflag

    good, ast1 = parse_factor()
    if not good then
        return false, nil
    end

    savelex = lexstr
    while matchString("*") or matchString("/") or matchString("%") do
        good, ast2 = parse_factor()
        if not good then
            return false, nil
        end
        ast3 = { { BIN_OP, savelex }, ast1, ast2 }
        ast1 = ast3
        savelex = lexstr
    end

    return true, ast1
end


function parse_factor()
    
    local good, ast1, ast2, savelex, arrayflag

    savelex = lexstr

    if matchString("(") then
        good, ast1 = parse_expr()
        if not good then
            return false, nil
        end
        if not matchString(")") then
            return false, nil
        end
        return true, ast1
    end

    if matchString("+") or matchString("-") or matchString("not") then
        good, ast1 = parse_factor()
        if not good then
            return false
        end
        return true, { { UN_OP, savelex }, ast1 }
    end

    if matchCat(lexit.NUMLIT) then
        return true, { NUMLIT_VAL, savelex }
    end

    if matchString("true") or matchString("false") then
        return true, { BOOLLIT_VAL, savelex }
    end

    if matchString("read") then
        if not matchString("(") then
            return false, nil
        end

        if not matchString(")") then
            return false, nil
        end

        return true, { READ_CALL }
    end

    if matchCat(lexit.ID) then
        
        if matchString("(") then
            if matchString(")") then
                return true, { FUNC_CALL, savelex }
            end
            return false, nil
        end

        if matchString("[") then
            good, ast1 = parse_expr()
            if not good then
                return false, nil
            end
            if not matchString("]") then
                return false, nil
            end
            
            return true, { ARRAY_VAR, savelex, ast1 }
        end

        return true, { SIMPLE_VAR, savelex }
    end

    return false, nil
end


return parseit