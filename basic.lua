local basic = {}
basic.cmds = {}
basic.funcs = {}
basic.mem = {}

basic.set_term = function(self, term)
	self.term = term
end

basic.print = function(self, text)
	if self.term and self.term.print then
		self.term.print(text)
	end
end

basic.read = function(self)
	if self.term and self.term.read then
		return self.term.read()
	else
		return ""
	end
end

basic.clear = function(self)
	if self.term and self.term.clear then
		self.term.clear()
	end
end

basic.patterns = {
	TT_NUM = { id=1, text="TT_NUM" },
	TT_CHAR = { id=2, text="TT_CHAR" },
	TT_LPAREN = { id=3, text="TT_LPAREN" },
	TT_RPAREN = { id=4, text="TT_RPAREN" },
	TT_PLUS = { id=5, text="TT_PLUS" },
	TT_MINUS = {id=6, text="TT_MINUS" },
	TT_MUL = {id=7, text="TT_MUL"},
	TT_DIV = {id=8, text="TT_DIV"},
	TT_COLON = {id=9, text="TT_COLON"},
	TT_COMMA = {id=10, text="TT_COMMA"},
	TT_SPACE = {id=11, text="TT_SPACE"},
	TT_STRING = {id=12, text="TT_STRING"},
	TT_NIL = { id=0, text="TT_NIL" },
}

basic.scan = function(self, line)
	local found = {}
	if string.sub(1,3) == "REM" then
		return found
	end
	local i=1
	while i <= string.len(line) do
		local char = string.sub(line, i, i)
		local byte = string.byte(char)
		if (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) then
			found[#found+1] = {pattern=self.patterns.TT_CHAR, char=char }
		elseif byte >= 48 and byte <= 57 then
			found[#found+1] = {pattern=self.patterns.TT_NUM, num=char}
		elseif char == "+" then
			found[#found+1] = {pattern=self.patterns.TT_PLUS}
		elseif char == "-" then
			found[#found+1] = {pattern=self.patterns.TT_MINUS}
		elseif char == "*" then
			found[#found+1] = {pattern=self.patterns.TT_MUL}
		elseif char == "/" then
			found[#found+1] = {pattern=self.patterns.TT_DIV}
		elseif char == "(" then
			found[#found+1] = {pattern=self.patterns.TT_LPAREN}
		elseif char == ")" then
			found[#found+1] = {pattern=self.patterns.TT_RPAREN}
		elseif char == ":" then
			found[#found+1] = {pattern=self.patterns.TT_COLON}
		elseif char == "," then
			found[#found+1] = {pattern=self.patterns.TT_COMMA}
		elseif char == " " then
			found[#found+1] = {pattern=self.patterns.TT_SPACE}
		elseif char == '"' then
			local str = ""
			i=i+1
			while string.sub(line, i, i) ~= "" and string.sub(line,i,i) ~= '"' do
				str=str..string.sub(line,i,i)
				i=i+1
			end
			found[#found+1] = {pattern=self.patterns.TT_STRING, str=str}
		else
			found[#found+1] = {pattern=self.patterns.TT_NIL}
		end
		i=i+1


	end
	return found
	
end

function basic:error(msg)
	self:print(msg)
end

function basic:skip_space(found)
	while found[found.cur] and found[found.cur].pattern == self.patterns.TT_SPACE do
		found.cur = found.cur + 1
	end
end
function basic:exec(found)
	local stop=false
	self.stop = function(self)
		stop=true
	end
	found.cur=1
	while found[found.cur] ~= nil and not stop do
		self:skip_space(found)
		if found[found.cur].pattern == self.patterns.TT_COLON then
			found.cur=found.cur+1
		else
			self:cmd(found)
		end
	end
	self.stop = nil
end

function basic:cmd(found)
	self:skip_space(found)
	local func = self:bezeichner(found)
	local args = {}
	if func then
		self:skip_space(found)
		while found[found.cur] and found[found.cur].pattern ~= self.patterns.TT_COLON do
			local arg, str= self:exp(found)	
			if str then
				args[#args+1] = str
			else
				args[#args+1] = arg
			end
			self:skip_space(found)
			if found[found.cur] and found[found.cur].pattern == self.patterns.TT_COMMA then
				found.cur = found.cur + 1
				self:skip_space(found)
			elseif found[found.cur] then
				self:error("Syntax error")
			end
		end
	end
	if self.cmds[func] then
		return self.cmds[func](self, args)
	end
	return 0
end

function basic:exp(found)
	local multi, str=self:multi(found)
	self:skip_space(found)
	while found[found.cur] do
		self:skip_space(found)
		if found[found.cur].pattern == self.patterns.TT_PLUS then
			if str then
				self:error("Integer expected")
			end
			found.cur= found.cur+1
			multi = multi + self:multi(found)
		elseif found[found.cur].pattern == self.patterns.TT_MINUS then
			if str then
				self:error("Integer expected")
			end
			found.cur = found.cur+1
			multi = multi - self:multi(found)
		else
			break
		end
	end
	return multi,str

end

function basic:multi(found)
	local val, str = self:func(found)
	self:skip_space(found)
	while found[found.cur] do
		self:skip_space(found)
		if found[found.cur].pattern == self.patterns.TT_MUL then
			if str then
				self:error("Integer expected")
			end
			found.cur = found.cur + 1
			val = val * self:func(found)
		elseif found[found.cur].pattern == self.patterns.TT_DIV then
			if str then
				self:error("Integer expected")
			end
			found.cur = found.cur + 1
			local par2 = self:func(found)
			if par2 == 0 then
				self:error("Division by zero")
			else
				val = val / par2
			end
		else
			break
		end
	end
	return val,str
end

function basic:func(found)
	local oldcur = found.cur
	self:skip_space(found)
	local func = self:bezeichner(found)
	self:skip_space(found)
	if found[found.cur] and found[found.cur].pattern == self.patterns.TT_LPAREN and func then
		found.cur=found.cur+1
		self:skip_space(found)
		if found[found.cur].pattern == self.patterns.TT_RPAREN then
			found.cur=found.cur+1
			if self.funcs[func] then
				return self.funcs[func](self, {})
			end
		else
			local args = {}
			while found[found.cur] and found[found.cur].pattern ~= self.patterns.TT_RPAREN do
				local val, str = self:exp(found)
				if str then
					args[#args+1] = str
				else
					args[#args+1] = val
				end
				self:skip_space(found)
				if found[found.cur] and found[found.cur].pattern == self.patterns.TT_COMMA then
					found.cur = found.cur + 1
				end
			end
			found.cur=found.cur+1
			if self.funcs[func] then
				return self.funcs[func](self, args)
			end
		end
	else
		found.cur = oldcur
		return self:klammer(found)
	end
end

function basic:klammer(found)
	local sign = 1
	self:skip_space(found)
	if found[found.cur] and (found[found.cur].pattern == self.patterns.TT_PLUS or found[found.cur].pattern == self.patterns.TT_MINUS) then
		if found[found.cur].pattern == self.patterns.TT_MINUS then
			sign = -1
		end
		found.cur = found.cur + 1
	end
	self:skip_space(found)
	if found[found.cur] and found[found.cur].pattern == self.patterns.TT_LPAREN then
		found.cur = found.cur + 1
		local value, str = self:exp(found)
		self:skip_space(found)
		if found[found.cur] and found[found.cur].pattern == self.patterns.TT_RPAREN then
			found.cur = found.cur + 1
			return value * sign, str
		else
			self:error("Expected TT_RPAREN")
			return 0
		end
	else
		local val, str = self:var(found)
		return val*sign, str
	end
end

function basic:zahl(found)
	self:skip_space(found)
	local num = ""
	if found[found.cur] and found[found.cur].pattern == self.patterns.TT_NUM then
		while found[found.cur] and found[found.cur].pattern == self.patterns.TT_NUM do
			num = num..found[found.cur].num
			found.cur = found.cur + 1
		end
		num = tonumber(num)
		return num
	else
		return 0
	end
end

function basic:var(found)
	self:skip_space(found)
	if not found[found.cur] then
		self:error("Integer expected")
		return 0
	end
	if found[found.cur].pattern == self.patterns.TT_NUM then
		return self:zahl(found)
	elseif found[found.cur].pattern == self.patterns.TT_CHAR then
		local val = self.mem[found[found.cur].char]
		found.cur=found.cur+1
		if val then
			return val
		else
			return 0
		end
	elseif found[found.cur].pattern == self.patterns.TT_STRING then
		local str = found[found.cur].str
		found.cur=found.cur+1
		return 0, str
	else
		found.cur=found.cur+1
		self:error("Syntax Error")
		return 0
	end
end

function basic:bezeichner(found)
	self:skip_space(found)
	if found[found.cur] and found[found.cur].pattern == self.patterns.TT_CHAR then
		local val = found[found.cur].char
		found.cur=found.cur+1
		while found[found.cur] and found[found.cur].pattern == self.patterns.TT_CHAR do
			val = val..found[found.cur].char
			found.cur = found.cur+1
		end
		return val
	else
		return nil
	end
end

return basic
