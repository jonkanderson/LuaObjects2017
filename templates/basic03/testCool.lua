local args = {...}
local config = dofile(assert(args[1]))
local CL, FN, COL, S = dofile(config.LuaRootDir..'/root.lua')

local Pm = FN.newPathManager()

local commandString = args[2]
local commandArgs = {}
for i=3,#args do table.insert(commandArgs, args[i]) end

--------------------------------------------------- Command List
local commands = {}
local commandUsageComments = {}

table.insert(commandUsageComments, "DoCool = Do something cool.")
function commands:DoCool()
	Pm:setModDir(config.MyModsDir)
	Pm:loadMod('modTestCoolX.lua')
	local x = FN.newInstance(CL.CoolThing)
	x:cool("I say")
end

table.insert(commandUsageComments, "Usage = Print this message.")
function commands:Usage()
	print("Usage:")
	for _,ea in ipairs(commandUsageComments) do
		print("\t"..ea)
	end
end

--------------------------------------------------- Process Command
local com = commands[commandString]
if com then
	com()
else
	commands["Usage"]()
end
