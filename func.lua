basic=...

--[[
	Function RND(MIN,MAX)
	Returns Random Number between MIN and MAX
	MIN AND MAX Are Optional
	Defaults: MIN=0, MAX=100
]]
basic.funcs.RND = function(self, args)
	local min = args[1]
	local max = args[2]
	if min == nil or type(min) ~= "number" then
		min=0
	end
	if max == nil or type(max) ~= "number" then
		max=100
	end
	if min > max then
		local old=max
		max=min
		min=old
	end
	
	return math.floor(math.random(min,max))
end

--[[
	Test Expression
	TEST(PAR1, OP, PAR2)
	OP = Operation:
		"==" = Equals
		">=" = Greater or Equals
		"<=" = Lesser or Equals
		">" = Greater
		"<" = Lesser
		"<>" = Not Equals
	If true it returns 1 else 0
]]
basic.funcs.TEST = function(self, args)
	local par1 = args[1]
	local mode = args[2]
	local par2 = args[3]
	if par1 and par2 and mode and type(mode)=="string" then
		if mode == "==" then
			if par1==par2 then
				return 1
			else
				return 0
			end
		elseif mode == "<>" then
			if par1~=par2 then
				return 1
			else
				return 0
			end
		else
			if type(par1)=="number" and type(par2)=="number" then
				if mode==">" then
					if par1>par2 then
						return 1
					else
						return 0
					end
				elseif mode=="<" then
					if par1<par2 then
						return 1
					else
						return 0
					end
				elseif mode=="<=" then
					if par1<=par2 then
						return 1
					else
						return 0
					end
				elseif mode==">=" then
					if par1>=par2 then
						return 1
					else
						return 0
					end
				else
					self:error("TEST: Unknown mode")

				end				
			else
				self:error("TEST: Operation illegal")
			end
		end
	else
		self:error("TEST: Inkorrect parameter")
	end
	return 0
end

--[[
	Concatenate more Values(numbers or strings)
	Returns string of result
]]
basic.funcs.CAT = function(self, args)
	local val=""
	for _, arg in ipairs(args) do
		val=val..arg
	end
	return 0, val
end

--[[
	Converts string to int
	returns int
]]
basic.funcs.TONUMBER = function(self, args)
	if args[1] and type(args[1]) =="string" then
		local num = args[1]:match("(%d+)")
		if num then
			return tonumber(num)
		else
			self:error("Not a number")
			return 0
		end
	else
		self:error("Not enoug arguments")
		return 0
	end
end
