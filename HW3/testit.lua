lexit = require "lexit"

str = "3"

Foo = lexit.lex("+12345")

while true do
    a, b = Foo()
    if a == nil or b == nil then break end
    print(a, b)
end