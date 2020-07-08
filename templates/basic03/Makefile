HERE=$(shell pwd -P)
HERE_NAME=$(notdir $(HERE))

LUAROOT_DIR=../..
COMMONMODS_DIR=$(LUAROOT_DIR)/mods
MYMODS_DIR=$(HERE)/mods
OUT_DIR=$(LUAROOT_DIR)/out/$(HERE_NAME)
CONFIG_FILE=$(OUT_DIR)/config.lua

.PHONY: all example

all: example

example: $(CONFIG_FILE)
	lua testCool.lua "$(CONFIG_FILE)" DoCool

$(CONFIG_FILE): Makefile
	mkdir -p "$(OUT_DIR)"
	printf "return {\n" > $@
	$(MAKE) config_contents
	printf "}\n" >> $@

config_contents::
	printf "LuaRootDir=\"%s\",\n" "$(LUAROOT_DIR)" >> "$(CONFIG_FILE)"
	printf "MyModsDir=\"%s\",\n" "$(MYMODS_DIR)" >> "$(CONFIG_FILE)"
	printf "CommonModsDir=\"%s\",\n" "$(COMMONMODS_DIR)" >> "$(CONFIG_FILE)"

pristine:
	rm -rf "$(OUT_DIR)"
