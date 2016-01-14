local basic = dofile("basic.lua")
basic:set_term(dofile("term.lua"))
basic.cmds.hello = function(self, args)
	local mesg = ""
	for _, msg in ipairs(args) do
		mesg=mesg..msg
	end
	print("hello"..mesg)
end
assert(loadfile("cmds.lua"))(basic)
assert(loadfile("func.lua"))(basic)
assert(loadfile("cli.lua"))(basic)
