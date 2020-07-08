local CL, FN, COL, S = ...

--====================================================== ByteStream
CL.ByteStream = FN.newSubclass(CL.Object, function(ThisInst)

function ThisInst:initOnString(aString)
	self._pos = 0
	self._string = aString
end

function ThisInst:initOnFile(absoluteFileName)
	self._pos = 0
	local f = assert(io.open(absoluteFileName, "rb"))
	local content = f:read("*all")
	f:close()
	self._string = content	
end

function ThisInst:position()
	return self._pos
end

function ThisInst:setPosition(anInteger)
	assert(anInteger >= 0)
	self._pos = anInteger
end

function ThisInst:atEnd()
	return self._pos >= #self._string
end

function ThisInst:getStringFromTo(start, finish)
	return string.sub(self._string, start+1, finish)
end

function ThisInst:restOfStreamString()
	return string.sub(self._string, self._pos+1, #self._string)
end

function ThisInst:getNext(anInteger)
	assert(anInteger >= 0)
	local s = string.sub(self._string, self._pos+1, self._pos+anInteger)
	self._pos = self._pos + string.len(s)
	return s
end

function ThisInst:incrementIfNextIsAnyOf(aString)
	return self:incrementIfNextAsciiMatch(function(val)
		for i = 1,string.len(aString) do
			if val == string.byte(aString, i) then return true end
		end
		return false
	end)
end

function ThisInst:incrementIfNextIsBetween(low, high)
	return self:incrementIfNextAsciiMatch(function(val)
		return val >= string.byte(low, 1) and val <= string.byte(high, 1)
	end)
end

function ThisInst:incrementIfNextAsciiMatch(aFunction)
	if self._pos == #self._string then return false end
	local newPos = self._pos + 1
	local val = string.byte(self._string, newPos)
	if aFunction(val) then
		self._pos = newPos
		return true
	else
		return false
	end
end

end)

--====================================================== ByteStreamToken
CL.ByteStreamToken = FN.newSubclass(CL.Object, function(ThisInst)

function ThisInst:init()
	self:superCall(ThisInst, "init")
	self._subtokens = {}
end

function ThisInst:setStream(aStream)
	self._stream = aStream
end

function ThisInst:setStart(anInteger)
	self._start = anInteger
end

function ThisInst:getStart()
	return self._start
end

function ThisInst:setFinish(anInteger)
	self._finish = anInteger
end

function ThisInst:length()
	return self._finish - self._start
end

function ThisInst:updateLengthToCurrentPosition()
	self._finish = self._stream:position()
	return self._finish - self._start
end

function ThisInst:addSubtoken(aToken)
	table.insert(self._subtokens, aToken)
end

function ThisInst:label(aString)
	self._label = aString
	return self
end

function ThisInst:getLabel(aString)
	return self._label
end

function ThisInst:asString()
	return self._stream:getStringFromTo(self._start, self._finish)
end

function ThisInst:debugString()
	local t = {}
	local s = string.format("[[%s]](%s, %d, %d)", 
		self:asString(), self._label, self._start+1, self._finish)
	table.insert(t, s)
	if #self._subtokens > 0 then
		table.insert(t, "(")
		for _,ea in ipairs(self._subtokens) do
			table.insert(t, ea:debugString())
		end
		table.insert(t, ")")
	end
	return table.concat(t)
end

end)

--====================================================== Scanner
CL.Scanner = FN.newSubclass(CL.Object, function(ThisInst)

function ThisInst:setStream(aStream)
	self._stream = aStream
end

function ThisInst:atEnd(aString)
	return self._stream:atEnd()
end

function ThisInst:setStreamFromString(aString)
	self._stream = CL.ByteStream:newInstance()
	self._stream:initOnString(aString)
end

function ThisInst:setStreamFromFilename(aPath)
	self._stream = CL.ByteStream:newInstance()
	self._stream:initOnFile(aPath)
end

function ThisInst:scanAllTokens()
	local col = {}
	local t = true
	while t and not self:atEnd() do
		t = self:nextToken()
		table.insert(col, t)
	end
	return col
end

function ThisInst:nextToken()
	-- Make a version of this method that scans what you want.
	return nil
end

function ThisInst:newToken()
	local t = CL.ByteStreamToken:newInstance()
	local pos = self._stream:position()
	t:setStream(self._stream)
	t:setStart(pos)
	t:setFinish(pos)
	return t
end

function ThisInst:newTokenFrom(aPosition)
	local t = CL.ByteStreamToken:newInstance()
	t:setStream(self._stream)
	t:setStart(aPosition)
	t:setFinish(self._stream:position())
	return t
end

function ThisInst:nilOrTokenFrom(aPosition)
	if aPosition == self._stream:position() then
		return nil
	else
		return self:newTokenFrom(aPosition)
	end
end

function ThisInst:manyAsciiMatch(aFunction)
	local pos = self._stream:position()
	while self._stream:incrementIfNextAsciiMatch(aFunction) do end
	return self:nilOrTokenFrom(pos)
end

function ThisInst:manyWhitespaces()
	local pos = self._stream:position()
	while self._stream:incrementIfNextIsAnyOf(" \t\n") do end
	return self:nilOrTokenFrom(pos)
end

function ThisInst:manyDigits()
	local pos = self._stream:position()
	while self._stream:incrementIfNextIsBetween("0", "9") do end
	return self:nilOrTokenFrom(pos)
end

function ThisInst:manyLetters()
	local pos = self._stream:position()
	local b = true
	while b do
		b = false
		b = self._stream:incrementIfNextIsBetween("a", "z")
		if not b then
			b = self._stream:incrementIfNextIsBetween("A", "Z")
		end
	end
	return self:nilOrTokenFrom(pos)
end

function ThisInst:ifNextMatchScan(aString, aFunction)
	local possibleToken = self:newToken()
	if aString then
		local t = self:nextMatch(aString)
		if not t then return nil end
		t:label("Start")
		possibleToken:addSubtoken(t)
	end
	local state = "continue"
	local userState = "start"
	while state == "continue" do
		state, userState = aFunction(possibleToken, userState)
		if state == "continue" then
		elseif state == "final" then
		elseif state == "abort" then
			self._stream:setPosition(possibleToken:getStart())
			return nil
		else
			error("Unexpected return state.")
		end
	end
	if possibleToken:updateLengthToCurrentPosition() > 0 then
		return possibleToken
	else
		return nil
	end
end

function ThisInst:nextAny(aString)
	if self._stream:atEnd() then return nil end
	local pos = self._stream:position()
	self._stream:getNext(1)
	return self:newTokenFrom(pos)
end


function ThisInst:nextMatch(aString)
	local pos = self._stream:position()
	local s = self._stream:getNext(string.len(aString))
	if s == aString then
		return self:newTokenFrom(pos)
	else
		self._stream:setPosition(pos)
		return nil
	end
end

function ThisInst:testMatch(aString)
	local pos = self._stream:position()
	local s = self._stream:getNext(string.len(aString))
	self._stream:setPosition(pos)
	if s == aString then
		return true
	else
		return false
	end
end

function ThisInst:restOfStreamString()
	return self._stream:restOfStreamString()
end

end)
