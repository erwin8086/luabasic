local basic = dofile("basic.lua")
basic:set_term(dofile("term.lua"))
local found = basic:scan(basic:read())
for _,pattern in ipairs(found) do
	local value=""
	if pattern.pattern == basic.patterns.TT_NUM then
		value = pattern.num
	elseif pattern.pattern == basic.patterns.TT_CHAR then
		value = pattern.char
	end
	
	print(pattern.pattern.text.."="..value)
end
basic.cmds.hello = function(self, args)
	local mesg = ""
	for _, msg in ipairs(args) do
		mesg=mesg..msg
	end
	print("hello"..mesg)
end
loadfile("cmds.lua")(basic)
basic.mem["A"] = 10
basic:exec(found)
