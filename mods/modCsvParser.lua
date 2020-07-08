local CL, FN, COL, S = ...

--[[
Todo:
- Create a way to give specific columns a conversion function.  (Like numbers and dates.)
- The BOM is recognized but basically ignored.  Test with international data.
--]]

if not (CL.ByteStreamToken and CL.Scanner) then
	error("Classes are missing which were originally provided by modScanner.lua")
end

--====================================================== (modified) Object
FN.modifyClass(CL.Object, function(ThisInst)

function ThisInst:isCsvHeader()
	return false
end

end)

--====================================================== (modified) ByteStreamToken
FN.modifyClass(CL.ByteStreamToken, function(ThisInst)

function ThisInst:asCsvString()
	local s = self:asString()
	if self._label == 'QuotedField' then
		local q = string.sub(s,1,1)
		s = string.sub(s, 2, -2)
		if q == '"' then s = string.gsub(s, '""', '"')
		elseif q == "'" then s = string.gsub(s, "''", "'")
		else error("Unrecognized quote character ("..q..").")
		end
	end
	return s
end

end)

--====================================================== CvsColumnHeader
CL.CvsColumnHeader = FN.newSubclass(CL.Object, function(ThisInst)

function ThisInst:setString(aString)
	self._string = aString
	self._keyString = aString
end

function ThisInst:getKeyString()
	return self._keyString
end

function ThisInst:isCsvHeader()
	return true
end

function ThisInst:debugString()
	return self._keyString
end

end)

--====================================================== CvsBbStyleColumnHeader
CL.CvsBbStyleColumnHeader = FN.newSubclass(CL.CvsColumnHeader, function(ThisInst)

function ThisInst:setString(aString)
	self._string = aString
	local a,b = string.find(aString, " %[")
	if a then
		self._keyString = string.sub(aString, 1, a-1)
		local c, d = string.find(aString, "%] |", b+1)
		self._argString = string.sub(aString, b+1, c-1)
		self._idString = string.sub(aString, d+1, #aString)
	else
		self._keyString = aString
	end
end

function ThisInst:debugString()
	if self._argString then
		return string.format("%s(%s,%s)",
			self._keyString, self._idString, self._argString)
	else
		return self._keyString
	end
end

end)

--====================================================== CsvParser
CL.CsvParser = FN.newSubclass(CL.Object, function(ThisInst)

function ThisInst:openFile(aPath)
	if not self._scanner then
		self:initScanner()
	end
	self._stream = assert(io.open(aPath, "r"))
end

function ThisInst:close()
	if self._stream then
		self._stream:close()
	end
	self._stream = nil
end

function ThisInst:nextLine()
	return self._stream:read("*line")
end

function ThisInst:readGenericHeader()
	local line = self:nextLine()
	if not line then return nil end
	self._scanner:setStreamFromString(line)
	local h = self._scanner:scanAllTokens()
	h = self:separateFieldsFrom(h)
	self._rawHeader = h
	return h
end

function ThisInst:readBasicHeader()
	local headers = self:readGenericHeader()
	headers = self:makeUniqKeysFor(headers)
	local col = {}
	for _,ea in ipairs(headers) do
		obj = CL.CvsColumnHeader:newInstance()
		obj:setString(ea)
		table.insert(col, obj)
	end
	self._headerKeys = col
	return col
end

function ThisInst:readBbStyleHeader()
	local headers = self:readGenericHeader()
	local col = {}
	for _,ea in ipairs(headers) do
		obj = CL.CvsBbStyleColumnHeader:newInstance()
		obj:setString(ea:asCsvString())
		table.insert(col, obj)
	end
	self._headerKeys = col
	return col
end

function ThisInst:makeUniqKeysFor(t)
	local originalKeys = {}
	for _,ea in ipairs(t) do
		table.insert(originalKeys, ea:asCsvString())
	end
	local counts = {}
	for _,ea in ipairs(originalKeys) do
		if counts[ea] then counts[ea] = counts[ea] + 1
		else counts[ea] = 0 end
	end
	for k in pairs(counts) do
		if counts[k] == 0 then counts[k] = nil end
	end
	local newKeys = {}
	for i=#originalKeys,1,-1 do
		k = originalKeys[i]
		if counts[k] then
			newKeys[i] = string.format("%s_%02d", k, counts[k]+1)
			counts[k] = counts[k] - 1
		else
			newKeys[i] = k
		end
	end
	return newKeys
end

function ThisInst:convertToStrings(t)
	local col = {}
	for _,ea in ipairs(t) do
		table.insert(col, t:asCsvString())
	end
	return col
end

function ThisInst:separateFieldsFrom(t)
	local col = {}
	for i=1,#t do
		if t[i]:getLabel() == "UnicodeBOM" then
		elseif t[i]:getLabel() == "Separator" then
			if i==#t or t[i+1]:getLabel() == "Separator" then
				local tok = self._scanner:newToken()
				tok:label("EmptyField")
				table.insert(col, tok)
			end
		else
			table.insert(col, t[i])
		end
	end
	return col
end

function ThisInst:readReadRowOrdered()
	local line = self:nextLine()
	if not line then return nil end
	self._scanner:setStreamFromString(line)
	local f = self._scanner:scanAllTokens()
	f = self:separateFieldsFrom(f)
	return f
end

function ThisInst:readReadRowKeyed()
	local t = self:readReadRowOrdered()
	if not t then return nil end
	local dict = {}
	for i,k in ipairs(self._headerKeys) do
		dict[k] = t[i]
	end
	return dict
end

function ThisInst:separator()
	return ","
end

function ThisInst:initScanner()
	local sc = CL.Scanner:newInstance()
	self._scanner = sc
	local sep = self:separator()
	function sc:nextToken()
		local token = nil

		--Scanning: BOM = [ 239, 187, 191 ]
		token = self:ifNextMatchScan(nil, function(newToken, state)
			if state == "start" then
				local c = self:nextAny()
				if string.byte(c:asString(), 1) ~= 239 then return "abort" end
				return "continue", 1
			elseif state == 1 then
				self:nextAny()
				return "continue", 2
			elseif state == 2 then
				self:nextAny()
				return "final"
			else
				error("Unhandled state: "..tostring(state))
			end
		end)
		if token then return token:label("UnicodeBOM") end

		--Scanning: QuotedField
		token = self:ifNextMatchScan('"', function()
			if self:nextMatch('""') then return "continue" end
			if self:nextMatch('"') and self:testMatch(",") then return "final" end
			if self:nextMatch('"') and self:atEnd() then return "final" end
			if self:atEnd() then return "final" end
			self:nextAny()
			return "continue"
		end)
		if token then return token:label("QuotedField") end

		token = self:ifNextMatchScan("'", function()
			if self:nextMatch("''") then return 'continue' end
			if self:nextMatch("'") and self:testMatch(sep) then return 'final' end
			if self:nextMatch("'") and self:atEnd() then return 'final' end
			if self:atEnd() then return "final" end
			self:nextAny()
			return 'continue'
		end)
		if token then return token:label('QuotedField') end

		--Scanning: GeneralField
		token = self:ifNextMatchScan(nil, function(newToken, state)
			if state == "start" then
				if self:atEnd() or self:testMatch(sep) then
					return "final", nil
				end
				self:nextAny()
				return "continue", "start"
			else
				error("Unhandled state: "..tostring(state))
			end
		end)
		if token then return token:label("GeneralField") end

		--Scanning: Separator
		token = self:nextMatch(sep)
		if token then return token:label("Separator") end

		--Scanning: EndOfLine (This should actually not be reached.)
		token = self:ifNextMatchScan(nil, function(newToken)
			if self:nextMatch("\n") then return "continue" end
			if self:nextMatch("\r") then return "continue" end
			return "final"
		end)
		if token then return token:label("EndOfLine") end

		print("Error: [["..self:restOfStreamString().."]]")
		error("No Token recognized.")
	end
end

end)
