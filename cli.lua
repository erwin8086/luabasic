local basic=...
-- Generate the cli structure
basic.cli = {}
basic.cli.exit=0

-- List the Programcode
basic.cmds.LIST = function(self, args)
	local startp = args[1]
	local endp = args[2]
	if not startp or not endp then
		startp=0
		endp=0
		for i, line in pairs(self.program) do
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
			if self.program[i] then
				self:print(i.." "..self.program[i])
			end
		end
	end
end

-- Programm to string
function basic.cli.prg2str(self)
	prg = ""
	for num, val in pairs(self.program) do
		prg = prg..num.." "..val.."\n"
	end
	return prg
end

-- Split from http://lua-users.org/wiki/SplitJoin
function split(self, sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end
-- String to Program
function basic.cli.str2prg(self, str)
	for _, line in ipairs(split(str, "\n")) do
		num, val = string.match(line, "(%d+) (.*)")
        	if val then
        		self.program[tonumber(num)] = val
	        else
        	        num = string.match(line, "(%d+)")
                	self.program[tonumber(num)] = nil
	        end
	end
end

-- Exit running cli
basic.cmds.EXIT = function(self, args)
	self.cli.exit=1
	if self.stop then
		self:stop()
	end
end

-- Run Programm
basic.cmds.RUN = function(self, args)
	self.cli.line=0
	self.cli.running=true
	self.cli.max=0
	for num, _ in pairs(self.program) do
		if num > self.cli.max then
			self.cli.max = num
		end
	end
end

-- End Programm
basic.cmds.END = function(self, args)
	self.cli.running=false
	if self.stop then
		self:stop()
	end
end
basic.cli.running=false
-- Parse Next Line
basic.cli.nextLine = function(self)
	local line = self.program[self.cli.line]
	while not line do
		self.cli.line=self.cli.line+1
		line = self.program[self.cli.line]
		if self.cli.line > self.cli.max then
			self.cli.running=false
			return
		end
	end
	local found = self:scan(line)
	self:exec(found)
	self.cli.line=self.cli.line+1
end

-- Goto Line
basic.cmds.GOTO = function(self, args)
	local line = args[1]
	if line then
		self.cli.line = line-1
		if self.stop then
			self:stop()
		end
	end
end

--[[
	CMD IF:
		IF PAR1, OP, PAR2, LINE
		IF CHECK, LINE
		OP = Operation:
			"==" = Equals
			">=" = Greater or Equals
			"<=" = Lesser or Equals
			">" = Greater
			"<" = Lesser
			"<>" = not Equals
		LINE Line to jump if true
		CHECK If Greater zero then true
]]
basic.cmds.IF = function(self, args)
	local par1 = args[1]
	local mode = args[2]
	local par2 = args[3]
	local line = args[4]
	local jump=false
	if par1 and mode and par2 and line and type(line)=="number" then
		if mode == "==" then
			if par1 == par2 then
				self.cli.line=line-1
				jump=true
			end
		elseif mode == "<>" then
			if par1 ~= par2 then
				self.cli.line=line-1
				jump=true
			end
		elseif type(par1)=="number" and type(par2)=="number" then
			if mode == ">" then
				if par1>par2 then
					self.cli.line=line-1
					jump = true
				end
			elseif mode == "<" then
				if par1<par2 then
					self.cli.line=line-1
					jump = true
				end
			elseif mode == "<=" then
				if par1<=par2 then
					self.cli.line=line-1
					jump = true
				end
			elseif mode == ">=" then
				if par1>=par2 then
					self.cli.line=line-1
					jump = true
				end
			else
				self:print("ERROR Unknowen mode!")
			end

		
		end
	else
		if par1 and type(par1) == "number" and mode and type(mode) == "number" then
			if par1 > 0 then
				self.cli.line=mode-1
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

--[[
	For Loop:
		FOR "VAR", MIN, MAX
		VAR = Variable( A-Z )
		MIN = Start value
		MAX = End value
]]
basic.cmds.FOR = function(self, args)
	if self.cli.for_single_line then
		return
	end
	local var = args[1]
	local startv = args[2]
	local endv = args[3]
	if var and startv and endv and type(var)=="string" and type(startv)=="number" and type(endv)=="number" then
		var = string.sub(var,1,1)
		self.mem[var] = startv
		self.cli.for_line = basic.cli.line
		self.cli.for_endv = endv
		self.cli.for_var = var
	end
end

--[[
	Close For Loop
	No Parameter
]]
basic.cmds.NEXT = function(self, args)
	if self.cli.for_line and self.cli.for_endv and self.cli.for_var then
		if self.cli.for_line == self.cli.line then
			self.cli.for_single_line=true
		end
		if self.mem[basic.cli.for_var] < self.cli.for_endv then
			self.mem[basic.cli.for_var] = self.mem[self.cli.for_var] + 1
			if not self.cli.for_single_line then
				self.cli.line=basic.cli.for_line
			else
				basic.cli.line=basic.cli.line-1
			end
			if self.stop then
				self:stop()
			end
		else
			self.cli.for_single_line=nil
			self.cli.for_line=nil
			self.cli.for_endv=nil
			self.cli.for_var=nil
		end
	end
end

--[[
	Do ... While Loop
	Starts Do ... While Loop.
]]
basic.cmds.DO = function(self,args)
	self.cli.do_line=self.cli.line
end

--[[
	WHILE PAR1
	Close Do ... While Loop
	if PAR1 > 0 jumps to Do else exits Do while loop
]]
basic.cmds.WHILE = function(self, args)
	if args[1] and type(args[1])=="number" and args[1]>0 and self.cli.do_line then
		self.cli.line=self.cli.do_line-1
	else
		self.cli.do_line=nil
	end
end

--[[
	Function LINE()
	Return current Line
	0 if not running
]]
basic.funcs.LINE = function(self, args)
	if self.cli.running then
		return self.cli.line
	else
		return 0
	end
end

--[[
	Reads and parses Line
]]
function basic.cli.readLine(self)
	local line = self:read()
	if string.match(string.sub(line,1,1),"%d") then
		num, val = string.match(line, "(%d+) (.*)")
		if val then
			self.program[tonumber(num)] = val
		else
			num = string.match(line, "(%d+)")
			self.program[tonumber(num)] = nil
		end
	else
		local found = self:scan(line)
		self:exec(found)
	end
end

--[[
	Command Line Interface
]]
function basic.cli.cli(self)
	while self.cli.exit==0 do
		self.cli.readLine(self)
		while self.cli.running do
			self.cli.nextLine(self)
		end
	end
end

