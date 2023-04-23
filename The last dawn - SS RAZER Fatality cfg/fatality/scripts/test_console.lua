local ffi = require "ffi"

local shell = ffi.load("kernel32.dll")

shell.AllocConsole ( )