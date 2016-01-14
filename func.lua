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
