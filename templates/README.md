# LuaObjects2017 Templates

These templates demonstrate ways in which one can organize a system using this object system.

## Basic01

This template has a basic main Lua file called `testCool.lua` and one module called `modTestCoolX.lua`. Within the example you will find that a new class is created called *CoolThing*.  There are demonstrations of defining methods on it, calling a method on the superclass, and adding methods to the class outside it's module file.

## Basic02

This pattern is similar to Basic 01.  The main difference is that it instantiates two separate systems  which are similar to each other but have independent behavior.  Objects instantiated from each respective system will respond accordingly.

## Basic03

This pattern is not so much about the Lua pattern, but rather about one way to organize a directory with a Makefile. The Makefile generates a `config.lua` file which contains paths and other settings which will be included by an instantiated Lua system.
