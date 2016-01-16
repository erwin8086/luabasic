local basic=...

-- Print Strings and Numbers
basic.cmds.PRINT = function(self, args)
	local msg = ""
	for _,txt in ipairs(args) do
		msg=msg..txt
	end
	self:print(msg)
end

-- Assings Variable
basic.cmds.LET = function(self, args)
	local var = args[1]
	local val = args[2]
	if var and val and type(val) == "number" then
		var = string.sub(var,1,1):upper()
		self.mem[var] = val
	end
	
end

--Clears The Screen
basic.cmds.CLEAR = function(self, args)
	self:clear()
end
