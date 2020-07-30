# LuaObjects2017

## Another OOP

LuaObjects2017 is a pattern for putting an Object-Oriented Programming (OOP) paradigm onto Lua.  Like others, it uses a [prototype-based](https://en.wikipedia.org/wiki/Prototype-based_programming) style.  However, my concerns were mainly creating a system that is easy to manage while maintaining decent execution speed.

The root class of the system is `CL.Object`.  Subclasses use the Lua metatable to extend a new object's behavior by reference rather than a copy.  In these directories you will find examples for:

- Creating a new class (prototype) with methods.
- Adding methods to an existing class.
- Creating a module file.

An object system is instantiated from `root.lua` and extended using various module files. Four variables are used to contain a complete system:

- Classes (CL)
- Functions (FN)
- Collections (COL)
- Singletons (S)

Just as in [Smalltalk](https://en.wikipedia.org/wiki/Smalltalk) programming, it is natural to add methods onto *Object* or other base class in order to extend the behavior of the system.

## Lua to C Binding

One of the nice features of Lua is its interface to C. Within the `libSources` directory is a demonstration for using the `modCWriter` module.  The file `build_jgsl.lua` generates C code to compile a shared library which makes available to Lua certain statistics functions from the [GNU Scientific Library](https://en.wikipedia.org/wiki/GNU_Scientific_Library).  Test code for the library is found in `tests/test_jgsl.lua`.

## Organization of Directory

- root.lua -- This defines a basic system.
- libSources -- Examples for generating C bindings.
- mods -- Contains a few modules.
- templates -- Some example patterns for using the system. (See its `README.md`.)
- tests -- Test code for modules.  (Very basic TDD ... does not use LuaUnit.)

## Disclaimer

Admittedly, this system is a one-person project. I have used it as the basis for many small projects in the past few years, but it has not been used in any collaborative project.  It implements a particular OOP style using select features of Lua.  The open style allows access and modification to all parts of a system.  This openness is much more manageable than it may seem on the surface.  A globally accessed class set is common for Smalltalk systems.  Each module in my Lua system is analogous to a *change set* in the Smalltalk world.

Jon Anderson (jonkanderson@gmail.com)
