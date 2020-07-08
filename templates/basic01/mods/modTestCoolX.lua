local CL, FN, COL, S = ...

--====================================================== Object (mod)
FN.modifyClass(CL.Object, function(ThisInst)
function ThisInst:cool(x)
	io.write(x)
	io.write(" ")
	io.write(self._dummy)
	io.write(" ")
	return 1000, 99
end
end)

--====================================================== CoolThing
CL.CoolThing = FN.newSubclass(CL.Object, function(ThisInst)

function ThisInst:myName()
	return 'Cool Thing'
end

function ThisInst:cool(x)
	self._dummy = "mildly"
	-- Call the "cool" method on the superclass which is Object. Pass in ThisInst, not self.
	local a,b = self:superCall(ThisInst, "cool", x)
	print("interesting. "..(a+b))
end

end)
