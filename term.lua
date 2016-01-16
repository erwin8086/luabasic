-- Minimal Terminal Library
local term = {}

term.print = print
term.read = io.read
term.clear = function()
	term.print("\n\n\n\n")
end

return term
