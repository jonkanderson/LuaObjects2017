--[[
This script generates a Lua interface library, jgsl.so, in order to 
access functions from GSL (GNU Scientific Library).  It is an example 
for showing how to use the module modCWriter.lua.

Build a CW library which provides these object constructors:
	Cdf -- Access to statistics functions.
	Rand -- Access to a good random number generator.
	Time -- Access to the system time.
--]]
local args = {...}
local cOutfilename = assert(args[1])
local libName = "jgsl"
local CL, FN, COL, S = dofile('../root.lua')

local Pm = FN.newPathManager()

Pm:setModDir('../mods')
Pm:loadMod('modCWriter.lua')

--------------
-- DO MAIN

local CW = CL.CWriter:newInstance()
CW:setOutfile(assert(io.open(cOutfilename, 'w')))
CW:luaIncludes()

-------------------------------------------------------
CW:include("gsl/gsl_cdf.h")

CW:buildObject('Cdf', function(Def)
Def:defineStruct("")
Def:defineCreate("")
--Def:defineFinalize("") -- No need to finalize if nothing could have been allocated.
Def:defineIndexAndSetSuper()


Def:defineMethodNoData("gaussianP", [[
	double x, sigma;
	x = luaL_checknumber(L, 2);
	sigma = luaL_checknumber(L, 3);
	lua_pushnumber(L, gsl_cdf_gaussian_P(x, sigma));
	return 1;
]])

Def:defineMethodNoData("gaussianPinv", [[
	double p, sigma;
	p = luaL_checknumber(L, 2);
	sigma = luaL_checknumber(L, 3);
	lua_pushnumber(L, gsl_cdf_gaussian_Pinv(p, sigma));
	return 1;
]])

Def:defineMethodNoData("tdistP", [[
	double x, nu; /* nu is the degrees of freedom */
	x = luaL_checknumber(L, 2);
	nu = luaL_checknumber(L, 3);
	lua_pushnumber(L, gsl_cdf_tdist_P(x, nu));
	return 1;
]])

Def:defineMethodNoData("tdistPinv", [[
	double p, nu; /* nu is the degrees of freedom */
	p = luaL_checknumber(L, 2);
	nu = luaL_checknumber(L, 3);
	lua_pushnumber(L, gsl_cdf_tdist_Pinv(p, nu));
	return 1;
]])

Def:defineMethodNoData("chisqP", [[
	double x, nu; /* nu is the degrees of freedom */
	x = luaL_checknumber(L, 2);
	nu = luaL_checknumber(L, 3);
	lua_pushnumber(L, gsl_cdf_chisq_P(x, nu));
	return 1;
]])

Def:defineMethodNoData("chisqPinv", [[
	double p, nu; /* nu is the degrees of freedom */
	p = luaL_checknumber(L, 2);
	nu = luaL_checknumber(L, 3);
	lua_pushnumber(L, gsl_cdf_chisq_Pinv(p, nu));
	return 1;
]])
end)

-------------------------------------------------------
CW:include("gsl/gsl_rng.h")
CW:include("gsl/gsl_randist.h")

CW:buildObject('Rand', function(Def)
Def:defineStruct([[
	gsl_rng *rng;
]])
Def:defineCreate([[
	long seed = luaL_checkinteger(L, 1);
	data->rng = gsl_rng_alloc(gsl_rng_mt19937); /* Mersenne Twister */
	gsl_rng_set(data->rng, seed);
]])
Def:defineFinalize([[
	if (data->rng) {
		gsl_rng_free(data->rng);
		data->rng = (gsl_rng *)NULL;
	}
]])
Def:defineIndexAndSetSuper()


Def:defineMethod("getInteger", [[
	lua_pushinteger(L, gsl_rng_get(data->rng));
	return 1;
]])

Def:defineMethod("getUniform", [[
	lua_pushnumber(L, gsl_rng_uniform(data->rng));
	return 1;
]])

Def:defineMethod("getGaussian", [[
	double sigma = 1;
	if(!lua_isnoneornil(L, 2)) {
		sigma = luaL_checknumber(L, 2);
	}
	lua_pushnumber(L, gsl_ran_gaussian(data->rng, sigma));
	return 1;
]])

Def:defineMethod("getChisq", [[
	double nu = luaL_checknumber(L, 2);
	lua_pushnumber(L, gsl_ran_chisq(data->rng, nu));
	return 1;
]])

Def:defineMethod("getTdist", [[
	double nu = luaL_checknumber(L, 2);
	lua_pushnumber(L, gsl_ran_tdist(data->rng, nu));
	return 1;
]])
end)

-------------------------------------------------------
CW:include("time.h")

CW:buildObject('Time', function(Def)
Def:defineStruct([[
	struct timespec tp;
]])
Def:defineCreate("")
--Def:defineFinalize("")
Def:defineIndexAndSetSuper()


Def:defineMethod("getSecAndNsec", [[
	clock_gettime(CLOCK_REALTIME, &data->tp);
	lua_pushinteger(L, data->tp.tv_sec);
	lua_pushinteger(L, data->tp.tv_nsec);
	return 2;
]])
end)

-------------------------------------------------------
CW:writeObjects()
CW:writeLuaOpenFunction(libName)
CW:closeOutfile()

