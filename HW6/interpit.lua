-- interpit.lua
-- Andrew Player
-- 2022
--
-- For CS331, Interprets AST from parseit.parse
-- for Ex 2, Assignment 6

local interpit = {}

--------------------------
--> Symbolic Constants <--
--------------------------

STMT_LIST   = 1
PRINT_STMT  = 2
RETURN_STMT = 3
ASSN_STMT   = 4
FUNC_CALL   = 5
FUNC_DEF    = 6
IF_STMT     = 7
WHILE_LOOP  = 8
STRLIT_OUT  = 9
CR_OUT      = 10
CHAR_CALL   = 11
BIN_OP      = 12
UN_OP       = 13
NUMLIT_VAL  = 14
BOOLLIT_VAL = 15
READ_CALL   = 16
SIMPLE_VAR  = 17
ARRAY_VAR   = 18

--------------------------
--> Utility Functions <--
--------------------------

local function numToInt(n)
    assert(type(n) == "number")

    if n >= 0 then
        return math.floor(n)
    else
        return math.ceil(n)
    end
end


local function strToNum(s)
    assert(type(s) == "string")

    local success, value = pcall(function() return tonumber(s) end)

    if success then
        if value == nil then
            return 0
        else
            return numToInt(value)
        end
    else
        return 0
    end
end


local function numToStr(n)
    assert(type(n) == "number")

    return tostring(n)
end


local function boolToInt(b)
    assert(type(b) == "boolean")

    if b then
        return 1
    else
        return 0
    end
end

-- ONLY FOR DEBUGGING
local function astToStr(x)
    local symbolNames = {
        "STMT_LIST", "PRINT_STMT", "RETURN_STMT", "ASSN_STMT",
        "FUNC_CALL", "FUNC_DEF", "IF_STMT", "WHILE_LOOP", "STRLIT_OUT",
        "CR_OUT", "CHAR_CALL", "BIN_OP", "UN_OP", "NUMLIT_VAL",
        "BOOLLIT_VAL", "READ_CALL", "SIMPLE_VAR", "ARRAY_VAR",
    }
    if type(x) == "number" then
        local name = symbolNames[x]
        if name == nil then
            return "<Unknown numerical constant: "..x..">"
        else
            return name
        end
    elseif type(x) == "string" then
        return '"'..x..'"'
    elseif type(x) == "boolean" then
        if x then
            return "true"
        else
            return "false"
        end
    elseif type(x) == "table" then
        local first = true
        local result = "{"
        for k = 1, #x do
            if not first then
                result = result .. ","
            end
            result = result .. astToStr(x[k])
            first = false
        end
        result = result .. "}"
        return result
    elseif type(x) == "nil" then
        return "nil"
    else
        return "<"..type(x)..">"
    end
end

-----------------------------------
--> Primary Function for Client <--
-----------------------------------

function interpit.interp(_ast, state, incall, outcall)

    -- print("\nAST:")
    -- print(astToStr(_ast))
    -- print()
    -- print("OUTPUT:")

    local interp_stmt_list
    local interp_stmt
    local eval_expr

    function interp_stmt_list(ast)
        for i = 2, #ast do
            interp_stmt(ast[i])
        end
    end

    function interp_stmt(ast)
        if ast[1] == PRINT_STMT then
            for i = 2, #ast do
                if ast[i][1] == STRLIT_OUT then
                    local str = ast[i][2]
                    outcall(str:sub(2, str:len() - 1))
                elseif ast[i][1] == CR_OUT then
                    outcall("\n")
                elseif ast[i][1] == CHAR_CALL then
                    local expr_ast = ast[i][2]
                    local str = eval_expr(expr_ast)
                    if str >= 256 or str < 0 then
                        outcall(utf8.char(0))
                    else
                        outcall(utf8.char(str))
                    end
                else
                    local val = eval_expr(ast[i])
                    outcall(numToStr(val))
                end
            end

        elseif ast[1] == FUNC_DEF then
            local funcname = ast[2]
            local funcbody = ast[3]
            state.f[funcname] = funcbody

        elseif ast[1] == FUNC_CALL then
            local funcname = ast[2]
            local funcbody = state.f[funcname]
            if funcbody == nil then
                funcbody = { STMT_LIST }
            end
            interp_stmt_list(funcbody)

        elseif ast[1] == RETURN_STMT then
            print("*** Not sure if this needs to exist.")

        elseif ast[1] == ASSN_STMT then

            if ast[2][1] == SIMPLE_VAR then

                local varname, varbody
    
                varname = ast[2][2]
                varbody = ast[3]
                state.v[varname] = eval_expr(varbody)
    
            elseif ast[2][1] == ARRAY_VAR then

                local varname, varindx, varbody
    
                varname = ast[2][2]
                varindx = eval_expr(ast[2][3])
                varbody = eval_expr(ast[3])
                if not state.a[varname] then
                    state.a[varname] = { [varindx] =  varbody }
                else
                    state.a[varname][varindx] = varbody
                end
            end

        elseif ast[1] == IF_STMT then

            local predicate = eval_expr(ast[2])

            -- if case
            if predicate then
                interp_stmt_list(ast[3])
            else
                local i = 4
                while i <= #ast do
                    -- elif case
                    if ast[i][1] ~= STMT_LIST then
                        local sub_predicate = eval_expr(ast[i])
                        i = i + 1
                        if (sub_predicate) then
                            interp_stmt_list(ast[i])
                            break
                        end
                    -- else case
                    else
                        interp_stmt_list(ast[i])
                        break
                    end
                    i = i + 1
                end
            end

        elseif ast[1] == WHILE_LOOP then
            local predicate = eval_expr(ast[2])
            while(predicate and predicate ~= 0) do
                interp_stmt_list(ast[3])
                predicate = eval_expr(ast[2])
            end
        end
    end

    function eval_expr(ast)
        local result

        if ast[1] == NUMLIT_VAL then
            result = strToNum(ast[2])

        elseif ast[1] == BOOLLIT_VAL then
            if ast[2] == "true" then
                result = 1
            else
                result = 0
            end

        elseif ast[1] == SIMPLE_VAR then

            local varname

            varname = ast[2]

            if not state.v[varname] then
                result = 0
            else
                result  = state.v[varname]
            end

        elseif ast[1] == ARRAY_VAR then

            local varname, varindx

            varname = ast[2]
            varindx = eval_expr(ast[3])

            if not state.a[varname] or not state.a[varname][varindx] then
                result = 0
            else
                result = state.a[varname][varindx]
            end

        elseif ast[1] == READ_CALL then
            
            local input = incall()
            if strToNum(input) then
                result = strToNum(input)
            else
                result = input
            end

        elseif ast[1][1] == BIN_OP then
            if ast[1][2] == "+" then
                result = eval_expr(ast[2]) + eval_expr(ast[3])
            elseif ast[1][2] == "-" then
                result = eval_expr(ast[2]) - eval_expr(ast[3])
            elseif ast[1][2] == "*" then
                result = eval_expr(ast[2]) * eval_expr(ast[3])
            elseif ast[1][2] == "/" then
                result = eval_expr(ast[2]) / eval_expr(ast[3])
            elseif ast[1][2] == "%" then
                result = eval_expr(ast[2]) % eval_expr(ast[3])
            elseif ast[1][2] == "==" then
                result = eval_expr(ast[2]) == eval_expr(ast[3])
            elseif ast[1][2] == "!=" then
                result = eval_expr(ast[2]) ~= eval_expr(ast[3])
            elseif ast[1][2] == "<" then
                result = eval_expr(ast[2]) < eval_expr(ast[3])
            elseif ast[1][2] == "<=" then
                result = eval_expr(ast[2]) <= eval_expr(ast[3])
            elseif ast[1][2] == ">" then
                result = eval_expr(ast[2]) > eval_expr(ast[3])
            elseif ast[1][2] == ">=" then
                result = eval_expr(ast[2]) >= eval_expr(ast[3])
            end
        
        elseif ast[1][1] == UN_OP then

            if ast[1][2] == "+" then
                result = 0 + eval_expr(ast[2])
            else
                result = 0 - eval_expr(ast[2])
            end

        else
            print(astToStr(ast))
        end

        return result
    end

    interp_stmt_list(_ast)
    return state
end

-------------
--> Export<--
-------------

return interpit