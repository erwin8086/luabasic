local basic=...
basic.program = {}
basic.cli = {}
basic.cli.exit=0
basic.cmds.LIST = function(self, args)
	local startp = args[1]
	local endp = args[2]
	if not startp or not endp then
		startp=0
		endp=0
		for i, line in pairs(basic.program) do
			if startp > i then
				startp=i
			end
			if endp < i then
				endp=i
			end
		end	
	end
	if startp and endp and type(startp)=="number" and type(endp)=="number" then
		for i=startp, endp do
			if basic.program[i] then
				self:print(i.." "..basic.program[i])
			end
		end
	end
end

basic.cmds.EXIT = function(self, args)
	basic.cli.exit=1
	if self.stop then
		self:stop()
	end
end

basic.cmds.RUN = function(self, args)
	basic.cli.line=0
	basic.cli.running=true
	basic.cli.max=0
	for num, _ in pairs(basic.program) do
		if num > basic.cli.max then
			basic.cli.max = num
		end
	end
end

basic.cmds.END = function(self, args)
	basic.cli.running=false
	if self.stop then
		self:stop()
	end
end
basic.cli.running=false
basic.cli.nextLine = function(self)
	local line = basic.program[basic.cli.line]
	while not line do
		basic.cli.line=basic.cli.line+1
		line = basic.program[basic.cli.line]
		if basic.cli.line > basic.cli.max then
			basic.cli.running=false
			return
		end
	end
	local found = self:scan(line)
	self:exec(found)
	basic.cli.line=basic.cli.line+1
end

basic.cmds.GOTO = function(self, args)
	local line = args[1]
	if line then
		basic.cli.line = line-1
		if self.stop then
			self:stop()
		end
	end
end

basic.cmds.IF = function(self, args)
	local par1 = args[1]
	local mode = args[2]
	local par2 = args[3]
	local line = args[4]
	local jump=false
	if par1 and mode and par2 and line and type(line)=="number" then
		if mode == "==" then
			if par1 == par2 then
				basic.cli.line=line-1
				jump=true
			end
		elseif mode == "<>" then
			if par1 ~= par2 then
				basic.cli.line=line-1
				jump=true
			end
		elseif type(par1)=="number" and type(par2)=="number" then
			if mode == ">" then
				if par1>par2 then
					basic.cli.line=line-1
					jump = true
				end
			elseif mode == "<" then
				if par1<par2 then
					basic.cli.line=line-1
					jump = true
				end
			elseif mode == "<=" then
				if par1<=par2 then
					basic.cli.line=line-1
					jump = true
				end
			elseif mode == ">=" then
				if par1>=par2 then
					basic.cli.line=line-1
					jump = true
				end
			else
				self:print("ERROR Unknowen mode!")
			end

		
		end
	else
		if par1 and type(par1) == "number" and mode and type(mode) == "number" then
			if par1 > 0 then
				basic.cli.line=mode-1
				jump = true
			end	
		end

	end
	if jump then
		if self.stop then
			self:stop()
		end
	end
end

basic.cmds.FOR = function(self, args)
	if basic.cli.for_single_line then
		return
	end
	local var = args[1]
	local startv = args[2]
	local endv = args[3]
	if var and startv and endv and type(var)=="string" and type(startv)=="number" and type(endv)=="number" then
		var = string.sub(var,1,1)
		basic.mem[var] = startv
		basic.cli.for_line = basic.cli.line
		basic.cli.for_endv = endv
		basic.cli.for_var = var
	end
end

basic.cmds.NEXT = function(self, args)
	if basic.cli.for_line and basic.cli.for_endv and basic.cli.for_var then
		if basic.cli.for_line == basic.cli.line then
			basic.cli.for_single_line=true
		end
		if basic.mem[basic.cli.for_var] < basic.cli.for_endv then
			basic.mem[basic.cli.for_var] = basic.mem[basic.cli.for_var] + 1
			if not basic.cli.for_single_line then
				basic.cli.line=basic.cli.for_line
			else
				basic.cli.line=basic.cli.line-1
			end
			if self.stop then
				self:stop()
			end
		else
			basic.cli.for_single_line=nil
			basic.cli.for_line=nil
			basic.cli.for_endv=nil
			basic.cli.for_var=nil
		end
	end
end

basic.cmds.DO = function(self,args)
	basic.cli.do_line=basic.cli.line
end

basic.cmds.WHILE = function(self, args)
	if args[1] and type(args[1])=="number" and args[1]>0 and basic.cli.do_line then
		basic.cli.line=basic.cli.do_line-1
	else
		basic.cli.do_line=nil
	end
end



while basic.cli.exit==0 do
	local line = basic:read()
	if string.match(string.sub(line,1,1),"%d") then
		num, val = string.match(line, "(%d+) (.*)")
		if val then
			basic.program[tonumber(num)] = val
		else
			num = string.match(line, "(%d+)")
			basic.program[tonumber(num)] = nil
		end
	else
		local found = basic:scan(line)
		basic:exec(found)
	end
	while basic.cli.running do
		basic.cli.nextLine(basic)
	end
end

