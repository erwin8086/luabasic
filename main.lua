local path=...
-- Loads all Components
local basic = assert(loadfile(path.."/basic.lua"))()
basic:set_term(assert(loadfile(path.."/term.lua"))())
assert(loadfile(path.."/cmds.lua"))(basic)
assert(loadfile(path.."/func.lua"))(basic)
assert(loadfile(path.."/cli.lua"))(basic)

-- New instance
function basic:new(n)
	n = n or {}
	setmetatable(n, self)
	self.__index = self
	n.cli = {}
	setmetatable(n.cli, self.cli)
	self.cli.__index = self.cli
	n.program = {}
	n.mem = {}
	return n
end

-- To Table
-- Change with state
function basic:to_table()
	local mem = {}
	mem.mem = self.mem
	mem.program = self.program
	mem.cli = self.cli
	return mem
end

-- From Table
function basic:from_table(mem)
	if mem then
		if mem.mem then
			self.mem = mem.mem
		end
		if mem.program then
			self.program = mem.program
		end
		if mem.cli then
			local cli = mem.cli
			setmetatable(cli, self.cli)
			self.cli.__index = self.cli
			self.cli = cli
		end
	end
end	

return basic
