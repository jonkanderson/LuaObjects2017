local args = {...}
local CL, FN, COL, S = dofile('../../root.lua')
-- CL is Classes, FN is Functions, COL is Collections, and S is Singletons.

local Pm = FN.newPathManager()
Pm:setArgs(args)
Pm:setHere('.')
Pm:setModDir('mods')

Pm:loadMod('modTestCoolX.lua')

--======================================================  Modify existing class, CoolThing
FN.modifyClass(CL.CoolThing, function(ThisInst)

function ThisInst:wow()
	print("Wow!")
end

end)

--====================================================== main code
-- The function reportAllKeys is good for debugging.
FN.reportAllKeys()

local x = FN.newInstance(CL.CoolThing)
print("--------")
x:cool("I say")
x:wow()

