local CL, FN, COL, S = ...

--====================================================== CWriter
CL.CWriter = FN.newSubclass(CL.Object, function(ThisInst)

function ThisInst:buildObject(name, aFunction)
	local obj = CL.CWriterObjectDef:newInstance()
	obj:initWithWriterAndName(self, name)
	table.insert(self._objectCollection, obj)
	aFunction(obj)
end

function ThisInst:closeOutfile(aFileStream)
	self.varOutfile:close()
	self.varOutfile = nil
end

--[[ Not used.
function ThisInst:funwritef(fmt, ...)
	local args = {...}
	return function()
		self:write(string.format(fmt, unpack(args)))
	end
end
--]]

function ThisInst:include(aHeaderString)
	if self._headersIncludes[aHeaderString] == nil then
		self:writef("#include \"%s\"\n", aHeaderString)
		self._headersIncludes[aHeaderString] = aHeaderString
	end
end

function ThisInst:ignore(...)
	-- Don't do anything.  This is another way to comment out a section.
end

function ThisInst:init()
	local super = getmetatable(ThisInst).__index
	super.init(self)
	self._headersIncludes = {}
	self._objectCollection = {}
end

function ThisInst:luaIncludes()
--	self:include("lua5.2/lua.h")
--	self:include("lua5.2/lauxlib.h")
	self:include("lua5.3/lua.h")
	self:include("lua5.3/lauxlib.h")
end

function ThisInst:objectsDo(aFunction)
	for _,ea in ipairs(self._objectCollection) do
		aFunction(ea)
	end
end

function ThisInst:objectsSize()
	return #self._objectCollection
end

function ThisInst:setOutfile(aFileStream)
	self.varOutfile = aFileStream
end

function ThisInst:write(aString)
	self.varOutfile:write(aString)
end

function ThisInst:writef(...)
	self:write(string.format(...))
end

function ThisInst:writeLuaOpenFunction(soName)
	self:write("\n/* ========================================================= OPEN "..soName.." */\n")
	self:write("int luaopen_"..soName.."(lua_State* L) {\n")
	self:write("\tint i;\n")
	self:write("\tlua_newtable(L);\n")
	self:write("\tfor(i=1; i<="..self:objectsSize().."; i++) {\n")
	self:objectsDo(function(ea)
		self:write("\t\tlua_pushstring(L, \""..ea:getObjectName().."\");\n")
		self:write("\t\tlua_pushcfunction(L, "..ea:getCreateFunctionName()..");\n")
		self:write("\t\tlua_rawset(L, -3);\n")	
	end)
	self:write("\t}\n")
	self:write("\treturn 1;\n")
	self:write("}\n")
end

function ThisInst:writeObjects()
	for _,ea in ipairs(self._objectCollection) do
		self:write("\n/* ========================================================= OBJECT "..ea:getObjectName().." */\n")
		self:write(ea:outString())
	end
end

--[[ Not used.
function ThisInst:writet(aTable)
	for _,ea in ipairs(aTable) do
		if type(ea) == 'string' then
			self:write(ea)
		elseif type(ea) == 'function' then
			self:write(ea())
		else
			self:write(tostring(ea))
		end
	end
end
--]]

end)

--====================================================== CWriterObjectDef
CL.CWriterObjectDef = FN.newSubclass(CL.Object, function(ThisInst)

function ThisInst:initWithWriterAndName(writer, name)
	self._objectName = name
	self._structName = "ls_"..name
	self._outStrings = {}
	self._index = #writer._objectCollection
	self._indexString = string.format("%04d", self._index)
	self._funcsName = "FUNCS"..self._indexString
	self._funcsTable = {}
	self._create = nil
end

----------------------------- Overloads:
function ThisInst:write(aString)
	table.insert(self._outStrings, aString)
end

----------------------------- New methods:
function ThisInst:defineStruct(aString)
	self:write("typedef struct {\n"..aString.."} "..self._structName..";\n")
end


function ThisInst:defineCreate(aString)
	self:write([[
static int l_create]]..self._indexString..[[(lua_State* L) {
	]]..self._structName..[[* data = (]]..self._structName..[[*)lua_newuserdata(L, sizeof(]]..self._structName..[[));
]]..aString..[[
	if(luaL_newmetatable(L, "]]..self._objectName..[[")) {
		luaL_setfuncs(L, ]]..self._funcsName..[[, 0);
	}
	lua_setmetatable(L, -2);
	return 1;
}
]])
self._create = "l_create"..self._indexString
end


function ThisInst:defineFinalize(aString)
	local indexedName = "l_finalize"..self._indexString
	self:write([[
static int l_finalize]]..self._indexString..[[(lua_State *L) {
	]]..self._structName..[[* data = (]]..self._structName..[[*)luaL_checkudata(L, 1, "]]..self._objectName..[[");
]]..aString..[[
	return 0;
}
]])
table.insert(self._funcsTable, "{\"__gc\", "..indexedName.."}")
end


function ThisInst:defineIndexAndSetSuper()
	local indexedName = "l_index"..self._indexString
	self:write([[
static int ]]..indexedName..[[(lua_State *L) {
	luaL_getmetatable(L, "]]..self._objectName..[[");
	lua_pushvalue(L, 2);
	lua_gettable(L, -2);
	if (!lua_isnil(L, -1)) {
		return 1;
	}
	lua_getuservalue(L, 1);
	lua_pushvalue(L, 2);
	lua_gettable(L, -2);
	return 1;
}
]])
table.insert(self._funcsTable, "{\"__index\", "..indexedName.."}")
indexedName = "l___setSuper"..self._indexString
self:write([[
static int ]]..indexedName..[[(lua_State *L) {
	lua_settop(L, 2);
	lua_setuservalue(L, 1);
	return 0;
}
]])
table.insert(self._funcsTable, "{\"__setSuper\", "..indexedName.."}")
end


function ThisInst:defineMethod(nm, aString)
	local indexedName = "l_"..nm..self._indexString
	self:write([[
static int ]]..indexedName..[[(lua_State* L) {
	]]..self._structName..[[* data = (]]..self._structName..[[*)luaL_checkudata(L, 1, "]]..self._objectName..[[");
]]..aString..[[
}
]])
table.insert(self._funcsTable, "{\""..nm.."\", "..indexedName.."}")
end


function ThisInst:defineMethodNoData(nm, aString)
	local indexedName = "l_"..nm..self._indexString
	self:write([[
static int ]]..indexedName..[[(lua_State* L) {
]]..aString..[[
}
]])
table.insert(self._funcsTable, "{\""..nm.."\", "..indexedName.."}")
end


function ThisInst:getCreateFunctionName()
	return self._create
end


function ThisInst:getObjectName()
	return self._objectName
end

function ThisInst:outString()
	local t = {}
	table.insert(t, "static const luaL_Reg "..self._funcsName.."[];\n")
	table.insert(t, table.concat(self._outStrings))
	table.insert(t, "static const luaL_Reg "..self._funcsName.."[] = {\n")
	for _,ea in ipairs(self._funcsTable) do
		table.insert(t, "\t"..ea..",\n")
	end
	table.insert(t, "\t{NULL,NULL}\n")
	table.insert(t, "};\n")
	return table.concat(t)
end

end)
