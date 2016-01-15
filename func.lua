basic=...
basic.funcs.RND = function(self, args)
	local min = args[1]
	local max = args[2]
	if min == nil or type(min) ~= "number" then
		min=0
	end
	if max == nil or type(max) ~= "number" then
		max=100
	end
	
	return math.floor(math.random(min,max+1))
end
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

				end				
			else

			end
		end
	end
end
