local args = {...}
local CL, FN, COL, S = dofile('../root.lua')

--[[
Todo:
- Create real assertions.
--]]

local Pm = FN.newPathManager()
Pm:setArgs(args)

Pm:setModDir('../mods')
Pm:loadMod('modScanner.lua')
Pm:loadMod('modCsvParser.lua')

--====================================================== main code
-- Good for debugging.
--FN.reportAllKeys()

local dataDir = "./testsCsvParser.data"
local pr = CL.CsvParser:newInstance()
local tokens

function myString(obj)
	if type(obj) == "string" then return obj
	--elseif obj:isCsvHeader() then return obj:getKeyString()
	elseif obj:isCsvHeader() then return obj:debugString()
	else return obj:asCsvString() end
	--else return obj:debugString() end
end

function printOrderedTable(t)
	print("--[[ printOrderedTable")
	for _,ea in ipairs(t) do print(myString(ea)) end
	print("--]]")
end

function printKeyedTable(t)
	print("--[[ printKeyedTable")
	for k,ea in pairs(t) do print(myString(k).." -> "..myString(ea)) end
	print("--]]")
end

--====================================================== libreoffice01.csv
local fn = dataDir.."/libreoffice01.csv"
pr:openFile(fn)
print("Testing data: "..fn)

local header = pr:readBasicHeader()
printOrderedTable(header)

local t
t = pr:readReadRowOrdered()
printOrderedTable(t)

t = pr:readReadRowKeyed()
printKeyedTable(t)

while t do
	t = pr:readReadRowOrdered()
	if t then printOrderedTable(t) end
end

pr:close()

--====================================================== bb01.csv
-- This file has a Unicode BOM.
local fn = dataDir.."/bb01.csv"
pr:openFile(fn)
print("Testing data: "..fn)

local header = pr:readBbStyleHeader()
printOrderedTable(header)

t = true
while t do
	t = pr:readReadRowKeyed()
	if t then printKeyedTable(t) end
end

pr:close()
