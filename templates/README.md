# LuaObjects2017 Templates

These templates demonstrate ways to organize a system using this object system.

## Basic01

This is a basic main Lua file called `testCool.lua` and one module `modTestCoolX.lua`. Within the example a new class is created called *CoolThing*.  There are demonstrations of defining methods, calling a method on the superclass, and adding methods to an existing class.

## Basic02

This pattern is similar to Basic 01.  The main difference is that two separate systems are created which are similar to each other.  Objects instantiated from each respective system will respond according to their respective system.

## Basic03

This directory is not interesting in the Lua.  The pattern is mainly about a style of directory organization with a Makefile.  A generated `config.lua` file is passed into the system containing paths and other settings.
