--[[
Copyright (c) 2017-present Jon K. Anderson

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

--[[
Version 2017-06-24

This is the root system.  After this file is included, expand your 
system by using methods like `loadMod(...)` on a path manager instance.
--]]
local CL = {}  -- Classes
local FN = {}  -- Functions
local COL = {} -- Collections
local S = {}   -- Singletons

--------------------------- Misc functions
-- FN.newSubclass is a utility to create a new class.
function FN.newSubclass(aClass, contentAdderFunction)
	local obj = {}
	setmetatable(obj, {__index=aClass})
	if contentAdderFunction ~= nil then
		contentAdderFunction(obj)
	end
	obj:init() -- Any classes referenced in init must exist. (This may be considered an error.) A solution might be to register the classes that need initialized into a singleton and then perform all of the initializations on the last recursive call of loadModAbs. (Maybe?)
	return obj
end

-- This version sets __className.
function FN.newSubclassByName(newName, superclassName, builderFunction)
	local superclass = assert(CL[superclassName])
	if CL[newName] then
		error("Class name duplicated.  Use FN.modifyClass instead.")
	end
	local newClass = FN.newSubclass(superclass, builderFunction)
	newClass.__className = newName
	CL[newName] = newClass
	return newClass
end

function FN.newInstance(aClass)
	local obj = FN.newSubclass(aClass)
	return obj
end

function FN.osCallEcho(cmd)
	print("-------------------------------[[")
	print(cmd)
	print("-----")
	print(assert(os.execute(cmd)))
	print("-------------------------------]]")
end

-- FN.make calls the make command in the OS to create the target.
function FN.make(target)
	local cmd = "make \""..assert(target).."\""
	FN.osCallEcho(cmd)
end

-- FN.modifyClass is a utility to add methods to a class that is already defined.
function FN.modifyClass(aClass, contentAdderFunction)
	contentAdderFunction(aClass)
	return aClass
end

function FN.addMethodsUsing(aClass, methodAdderFunction)
	methodAdderFunction(aClass)
end

function FN.shallowCopyCollection(aCollection)
	local newCol = {}
	for _,ea in ipairs(aCollection) do
		table.insert(newCol, ea)
	end
	return newCol
end

function FN.reportAllKeys()
	local function printTable(aTable)
		local col = {}
		for k in pairs(aTable) do table.insert(col, k) end
		table.sort(col)
		for _,k in ipairs(col) do print("\t"..k) end
	end

	print("Classes:")
	printTable(CL)

	print("Functions:")
	printTable(FN)

	print("Collections:")
	printTable(COL)

	print("Singletons:")
	printTable(S)
end

--------------------------- Object class
CL.Object = FN.newSubclass({}, function(ThisInst)

function ThisInst:addLocalKeysTo(targetCol)
	for k,_ in pairs(self) do
		table.insert(targetCol, k)
	end
end

function ThisInst:allKeys()
	local col = {}
	ThisInst:addLocalKeysTo(col)
	local obj = self
	while obj ~= ThisInst do
		obj:addLocalKeysTo(col)
		obj = getmetatable(obj).__index
	end
	return col
end

function ThisInst:getClassName()
	local n = rawget(self, "__className")
	if n then
		return tostring(n).." instance prototype"
	end
	local m = getmetatable(self).__index
	n = rawget(m, "__className")
	if n then
		return tostring(n)
	end
	n = m["__className"]
	if n then
		return "A subclass of "..tostring(n)
	end
	return "Unknown"
end

function ThisInst:getClass()
	return getmetatable(self).__index
end

function ThisInst:init() end

function ThisInst:superCall(aClass, selector, ...)
	local targetClass = assert(getmetatable(aClass)).__index
	return targetClass[selector](self, ...)
end

function ThisInst:asMyInstance(aTableToBecomeObject)
	setmetatable(aTableToBecomeObject, {__index=self})
	aTableToBecomeObject:init()
	return aTableToBecomeObject
end

function ThisInst:protoChild()
	local obj = {}
	setmetatable(obj, {__index=self})
	return obj
end

function ThisInst:newInstance()
	return FN.newInstance(self)
end

end)

--------------------------- PathManager class
CL.PathManager = FN.newSubclass(CL.Object, function(ThisInst)

function ThisInst:setArgs(args)
	self._args = args end
function ThisInst:setPaths(paths)
	self._paths = paths end
function ThisInst:getPathFor(aString)
	return self._paths[aString]
end
function ThisInst:setRoot(aPath)
	self._root = aPath end
function ThisInst:setHere(aPath)
	self._here = aPath end
function ThisInst:setModDir(aPath)
	self._modDir = aPath end
function ThisInst:getModDir()
	return self._modDir end

function ThisInst:pasteDirs(a, b)
	return a .. "/".. b
end

function ThisInst:relToRoot(relPath)
	return self:pasteDirs(self._root, relPath)
end

function ThisInst:relToHere(relPath)
	return self:pasteDirs(self._here, relPath)
end

function ThisInst:relToModDir(relPath)
	return self:pasteDirs(self._modDir, relPath)
end

function ThisInst:loadedFile(absPath)
	local f = self._loadedFiles[absPath]
	if f == nil then
		f = assert(loadfile(absPath))
		self._loadedFiles[absPath] = f
	end
	return f
end

function ThisInst:loadModAbs(absPath)
	local f = self._loadedFiles[absPath]
	if f == nil then
		f = assert(loadfile(absPath))
		self._currentFileName = absPath
		self._loadedFiles[absPath] = f
		f(CL, FN, COL, S)
		self._currentFileName = nil
	end
end

function ThisInst:callFile(absPath, ...)
	return self:loadedFile(absPath)(...)
end

function ThisInst:callMod(absPath, ...)
	local f = self:loadedFile(absPath)
	return f(CL, FN, COL, S, ...)
end

function ThisInst:loadMod(relPath)
	self:loadModAbs(self:relToModDir(relPath))
end

function ThisInst:loadModRelToHere(relPath)
	self:loadModAbs(self:relToHere(relPath))
end

function ThisInst:init()
	self._loadedFiles = {}
	self._here = '.'
end

end)

function FN.newPathManager()
	S.PathManager = FN.newInstance(CL.PathManager)
	return S.PathManager
end

--------------------------- Return
return CL, FN, COL, S
