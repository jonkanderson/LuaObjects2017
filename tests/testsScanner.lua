local args = {...}
local CL, FN, COL, S = dofile('../root.lua')

local Pm = FN.newPathManager()
Pm:setArgs(args)
Pm:setHere('.')
Pm:setModDir('../mods')

Pm:loadMod('modScanner.lua')

--====================================================== main code
-- Good for debugging.
--FN.reportAllKeys()

local sc = CL.Scanner:newInstance()
local tokens

local text = [[0293893 hello900   'this is '' a string'
		begin some stuff begin other end end]]

sc:setStreamFromString(text)

function sc:nextToken()
	local token = nil

	token = self:ifNextMatchScan("begin", function(newToken, state)
		if state == "start" then
			local t = self:manyWhitespaces()
			if not t then return "abort" end
			newToken:addSubtoken(t)
			return "continue", "content"
		elseif state == "content" then
			if self:testMatch("end") then
				return "continue", "final"
			else
				t = self:nextToken()
				if not t then return "abort" end
				newToken:addSubtoken(t)
			end
			return "continue", "content"
		elseif state == "final" then
			t = self:nextToken()
			newToken:addSubtoken(t)
			return "final", nil
		else
			error("Unhandled state: "..tostring(state))
		end
	end)
	if token then return token:label("BeginEndChunk") end

	token = self:manyWhitespaces()
	if token then return token:label("Whitespace") end

	token = self:manyDigits()
	if token then return token:label("Digits") end

	token = self:manyLetters()
	if token then return token:label("Letters") end

	token = self:ifNextMatchScan("'", function()
		if self:nextMatch("''") then return "continue" end
		if self:nextMatch("'") then return "final" end
		if self:atEnd() then return "abort" end
		self:nextAny()
		return "continue"
	end)
	if token then return token:label("String") end

	error("No Token recognized.")
end

print("Parsing Text:")
print(">>"..text.."<<")

tokens = sc:scanAllTokens()
for _,t in ipairs(tokens) do
	print(t:debugString())
end
assert(#tokens == 8)
