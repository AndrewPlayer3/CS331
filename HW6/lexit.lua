-- Filename: lexit.lua
-- Created By: Andrew Player
-- Last Modified: 02/15/2022
-- Description: Lexer Module for Assignment 3 of CS331


local lexit = {}


lexit.KEY    = 1
lexit.ID     = 2
lexit.NUMLIT = 3
lexit.STRLIT = 4
lexit.OP     = 5
lexit.PUNCT  = 6
lexit.MAL    = 7


lexit.catnames = {
    "Keyword"       ,
    "Identifier"    ,
    "NumericLiteral",
    "StringLiteral" ,
    "Operator"      ,
    "Punctuation"   ,
    "Malformed"
}


local function isLetter(c)

    if c:len() ~= 1      then
        return false

    elseif c:match("%a") then
        return true
    end

    return false
end


local function isDigit(c)

    if c:len() ~= 1      then
        return false

    elseif c:match("%d") then
        return true
    end

    return false
end


local function isWhitespace(c)

    if c:len() ~= 1      then
        return false

    elseif c:match("%s") then
        return true
    end

    return false
end


local function isPrintableASCII(c)

    if c:len() ~= 1            then
        return false

    elseif c:match("[%w%p%s]") then
        return true
    end

    return false
end


local function isIllegal(c)

    if c:len() ~= 1            then
        return false

    elseif isWhitespace(c)     then
        return false

    elseif isPrintableASCII(c) then
        return false
    end

    return true
end


function lexit.lex(program)


    --> Lexer Variables <--
    -----------------------


    local pos          -- Index of next character in program
    local state        -- Current state of our state machine
    local ch           -- Current character
    local lexstr       -- The lexeme so far
    local category     -- Category of lexeme when state is set to DONE
    local handlers     -- Dispatch table
    local currentQuote -- Keep track of quotes for string literals.


    --> States <--
    --------------


    local DONE     = 0
    local START    = 1
    local LETTER   = 2   -- a-zA-Z
    local DIGIT    = 3   -- 0-9
    local DOT      = 5   -- .
    local QUOTE    = 6   -- ' "


    --> Keywords <--
    ----------------


    local keywords = {
        "and"   ,
        "char"  ,
        "cr"    ,
        "elif"  ,
        "else"  ,
        "false" ,
        "func"  ,
        "if"    ,
        "not"   ,
        "or"    ,
        "print" ,
        "read"  ,
        "return",
        "true"  ,
        "while"
    }


    --> Character Utility Functions <--
    -----------------------------------


    -- Return the current character (char at pos)
    local function currentChar()
        return program:sub(pos, pos)
    end


    -- Return the next character (char at pos + 1)
    local function nextChar()
        return program:sub(pos + 1, pos + 1)
    end


    -- Skip the character at pos
    local function drop1()
        pos = pos + 1
    end


    -- Add the current character to the lexeme
    local function add1()
        lexstr = lexstr .. currentChar()
        drop1()
    end


    -- Skip whitespace and comments, move pos to the next lexeme 
    local function skipToNextLexeme()

        while true do

            -- Skip whitespace
            while isWhitespace(currentChar()) do
                drop1()
            end

            -- If this isn't a comment, stop skipping
            if currentChar() ~= '#' then
                break
            end

            -- Skip Comment

            drop1() -- Drop leading #

            while true do

                -- Our comments should go to EOL no matter what
                if currentChar() == ""   then
                    return
                end

                if currentChar() == "\n" then

                    drop1()

                    while(isWhitespace(currentChar())) do
                        drop1()
                    end

                    return
                end

                drop1()
            end
        end
    end


    --> State Handler Functions <--
    -------------------------------


    -- State DONE: lexeme is done (this should not be called)
    local function handle_DONE()
        error("'DONE' state should not be handled!\n")
    end


    -- State START: no character has been read yet
    local function handle_START()

        if isIllegal(ch)                    then
            add1()
            state    = DONE
            category = lexit.MAL

        elseif currentChar() == "#"         then
            skipToNextLexeme()

        elseif isLetter(ch) or ch == '_'    then
            add1()
            state = LETTER

        elseif isDigit(ch)                  then
            add1()
            state = DIGIT

        elseif ch == '.'                    then
            add1()
            state = DOT

        elseif ch == '='                    then
            add1()

            if currentChar() == '=' then
                add1()
            end

            state    = DONE
            category = lexit.OP

        elseif ch == '!'                    then
            add1()

            if currentChar() == '=' then
                add1()
                state    = DONE
                category = lexit.OP

            else
                add1()
                state    = DONE
                category = lexit.PUNCT

            end

        elseif ch == '<' then
            add1()
            if currentChar() == '='         then
                add1()
            end
            state    = DONE
            category = lexit.OP

        elseif ch == '>'                    then
            add1()

            if currentChar() == '=' then
                add1()
            end

            state    = DONE
            category = lexit.OP

        elseif ch:match("[%%%/%[%]%+%-%*]") then
            add1()
            state    = DONE
            category = lexit.OP

        elseif ch:match("[\'\"]")           then
            currentQuote = ch
            add1()
            state = QUOTE

        else
            add1()
            state    = DONE
            category = lexit.PUNCT

        end
    end


    -- State LETTER: we are in an Identifier
    local function handle_LETTER()

        if isLetter(ch) or ch == '_' or isDigit(ch) then

            add1()
        else

            state = DONE

            for i = 0, 15, 1 do

                if lexstr == keywords[i] then
                    category = lexit.KEY
                    return
                end
            end

            category = lexit.ID
        end
    end


    -- State DIGIT: we are in a NUMLIT, and we have not seen '.'.
    local function handle_DIGIT()

        if isDigit(ch)                     then
            add1()

        elseif currentChar():match("[eE]") then
            pos = pos + 1

            if currentChar():match("+") then

                if(isDigit(nextChar())) then

                    pos = pos - 1

                    add1()
                    add1()

                    while(isDigit(currentChar())) do
                        add1()
                    end

                    state    = DONE
                    category = lexit.NUMLIT

                else
                    pos      = pos - 1
                    state    = DONE
                    category = lexit.NUMLIT
                end

            elseif isDigit(currentChar()) then

                pos = pos - 1

                add1()

                while isDigit(currentChar()) do
                    add1()
                end

                state    = DONE 
                category = lexit.NUMLIT

            else
                pos      = pos - 1
                state    = DONE
                category = lexit.NUMLIT
            end

        elseif ch == '.' then
            state    = DONE
            category = lexit.NUMLIT

        else
            state   = DONE
            category = lexit.NUMLIT
        end
    end


    -- State DOT: We have seen a "." and nothing else.
    local function handle_DOT()
        state    = DONE
        category = lexit.PUNCT
    end


    -- State QUOTE: We have seen a ' or " and nothing else.
    local function handle_QUOTE()

        while true do

            if currentChar() == "" or currentChar() == "\n" then
                state    = DONE
                category = lexit.MAL
                break

            elseif currentChar():match(currentQuote)        then
                add1()
                state    = DONE
                category = lexit.STRLIT
                break
            end

            add1()
        end
    end


    handlers = {
        [DONE  ]  = handle_DONE  ,
        [START ]  = handle_START ,
        [LETTER]  = handle_LETTER,
        [DIGIT ]  = handle_DIGIT ,
        [DOT   ]  = handle_DOT   ,
        [QUOTE ]  = handle_QUOTE ,
    }


    local function getLexeme(dummy1, dummy2)

        if pos > program:len() then
            return nil, nil
        end

        lexstr = ""
        state  = START

        while state ~= DONE do
            ch = currentChar()
            handlers[state]()
        end

        skipToNextLexeme()
        return lexstr, category
    end


    pos = 1
    skipToNextLexeme()
    return getLexeme, nil, nil
end

return lexit












