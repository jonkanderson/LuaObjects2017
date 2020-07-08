local args = {...}

function newSystem()
	local CL, FN, COL, S = dofile('../../root.lua')

	local Pm = FN.newPathManager()
	Pm:setArgs(args)
	Pm:setHere('.')
	Pm:setModDir('..')

	Pm:loadModRelToHere('testCoolModX.lua')

	return {CL=CL, FN=FN, COL=COL, S=S}
end

local sys1 = newSystem()
local sys2 = newSystem()

--====================================================== CoolThing (mod sys1)
sys1.FN.modifyClass(sys1.CL.CoolThing, function(ThisInst)
function ThisInst:cool(x)
	self._dummy = "mildly"
	local a,b = self:superCall(ThisInst, "cool", x)
	print("interesting. "..(a+b))
end
end)

--====================================================== CoolThing (mod sys2)
sys2.FN.modifyClass(sys2.CL.CoolThing, function(ThisInst)
function ThisInst:cool(x)
	self._dummy = "very"
	local a,b = self:superCall(ThisInst, "cool", x)
	print("Cool! "..(a+b))
end
end)

--====================================================== main code
-- Good for debugging.
sys1.FN.reportAllKeys()

local x = sys1.FN.newInstance(sys1.CL.CoolThing)
local y = sys2.FN.newInstance(sys2.CL.CoolThing)
x:cool("I say")
y:cool("I say")

