--[=[
--]=]

package.cpath = package.cpath..';../out/lib/?.so'
local constructors = require('jgsl')

local jCdf = constructors.Cdf()
print("N(0,1), x<-2.5, p=", jCdf:gaussianP(-2.5, 1)) -- pnorm(-2.5, 0, 1)
print("N(0,1), p<0.05, x=", jCdf:gaussianPinv(0.05, 1)) -- qnorm(0.05, 0, 1)
print("N(2,10), x<1.7, p=", jCdf:gaussianP(1.7-2, 10)) -- pnorm(1.7, 2, 10)
print("N(2,10), p<0.30, x=", jCdf:gaussianPinv(0.30, 10)+2) -- qnorm(0.30, 2, 10)
print("t_3, x<-1, p=", jCdf:tdistP(-1, 3)) -- pt(-1, 3)
print("t_3, p<0.2, x=", jCdf:tdistPinv(0.2, 3)) -- qt(0.2, 3)
print("X^2(3), x>2.2, p=", 1-jCdf:chisqP(2.2, 3)) -- 1-pchisq(2.2, 3)
print("X^2(3), p<0.95, x=", jCdf:chisqPinv(0.95, 3)) -- qchisq(0.95, 3)

local jTime = constructors.Time()
local epocSec,nanoSec = jTime:getSecAndNsec()
print("Seconds since epoc =", epocSec)
print("nanoSec=", nanoSec)

--local jRand = constructors.Rand(nanoSec)
local jRand = constructors.Rand(992291721)
print("Some random numbers:")
for i=1,5 do
	print(" Integer", jRand:getInteger())
end
for i=1,5 do
	print(" Uniform", jRand:getUniform())
end
print(" N(0,1)", jRand:getGaussian())
print(" N(0,1)", jRand:getGaussian(1))
print(" N(0,100)", jRand:getGaussian(100))
print(" N(0,100)", jRand:getGaussian(100))
print(" X^2(3)", jRand:getChisq(3))
print(" X^2(3)", jRand:getChisq(3))
print(" t_3", jRand:getTdist(3))
print(" t_3", jRand:getTdist(3))

