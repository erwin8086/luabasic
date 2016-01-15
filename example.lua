basic = assert(loadfile("main.lua"))(".")

local a = basic:new()
a.cli.cli(a)
