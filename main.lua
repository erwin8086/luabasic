local path=...
local basic = dofile(path.."/basic.lua")
basic:set_term(dofile(path.."/term.lua"))
basic.cmds.hello = function(self, args)
	local mesg = ""
	for _, msg in ipairs(args) do
		mesg=mesg..msg
	end
	print("hello"..mesg)
end
assert(loadfile(path.."/cmds.lua"))(basic)
assert(loadfile(path.."/func.lua"))(basic)
assert(loadfile(path.."/cli.lua"))(basic)
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

function basic:to_table()
	local mem = {}
	mem.mem = self.mem
	mem.program = self.program
	mem.cli = self.cli
	return mem
end

function basic:from_table(mem)
	self.mem = mem.mem
	self.program = mem.program
	local cli = mem.cli
	setmetatable(cli, self.cli)
	self.cli.__index = self.cli
	self.cli = cli
end

return basic
