-- Loads sandboxed Basic Interpreter
local basic = assert(loadfile("sandbox.lua"))(".")
-- Creates Instance
local a = basic:new()
-- Starts Command Line Interface
a.cli.cli(a)
