lexit = require "lexit"

STR = "12#a\n#b\n#c\nab"

Foo = lexit.lex(STR)

while true do
    local a, b = Foo()
    if a == nil or b == nil then break end
    print(a, b)
end