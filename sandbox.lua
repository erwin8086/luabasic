local path=...

-- Files allowed to Load from Basic
local files = {}
local function allow_file(fname)
	files[path..fname]=true
end
allow_file("/basic.lua")
allow_file("/cli.lua")
allow_file("/cmds.lua")
allow_file("/func.lua")
allow_file("/term.lua")

-- Create Sandbox
sandbox = {}
sandbox.print = print
sandbox.io = {}
sandbox.io.read = io.read
sandbox.math = math
sandbox.assert = assert
sandbox.setmetatable = setmetatable
sandbox.string = string
sandbox.pairs = pairs
sandbox.ipairs = ipairs
sandbox.tonumber = tonumber
sandbox.type = type
local basic
if _VERSION == "Lua 5.2" then
	-- Sets loadfile for sandbox to only loads save files
	local function save_loadfile(fname)
		if files[fname] == true then
			return loadfile(fname, "bt", sandbox)
		else
			return nil
		end
	end
	sandbox.loadfile = save_loadfile

	-- load basic in sandbox
	basic = assert(loadfile(path.."/main.lua", "bt", sandbox))(path)
elseif _VERSION == "Lua 5.1" then
	allow_file("/main.lua")
	local function save_loadfile(fname)
		if files[fname] == true then
			return loadfile(fname)
		else
			return nil
		end
	end
	sandbox.loadfile = save_loadfile

	setfenv(1, sandbox)

	-- load basic in sandbox
	basic = assert(loadfile(path.."/main.lua"))(path)
		
end

return basic
