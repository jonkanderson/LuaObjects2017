LUAROOT_DIR=..
OUT_DIR=$(LUAROOT_DIR)/out
LUA=/usr/bin/lua

JGSL_LIB=$(LUAROOT_DIR)/out/lib/jgsl.so

.PHONY: all all_tests
all:
	@echo "These tests were used to drive development of the corresponding mods."
	@echo "  testsCsvParser.lua: Parses CSV files found in the directory testsCsvParser.data."
	@echo "  testsScanner.lua: A basic parsing utility."
	@echo "  test_jgsl.lua: Test GSL Lua interface library.  Run 'make all' from ../libSources."
	@echo "Type 'make all_tests' to diff each with the output in the regression_data directory."

.PHONY: all_tests test_jgsl test_CsvParser test_Scanner
all_tests: test_jgsl test_CsvParser test_Scanner

test_jgsl:
	mkdir -p "$(OUT_DIR)"
	cd $(LUAROOT_DIR)/libSources ; $(MAKE) $(JGSL_LIB)
	@echo "** NOTE: Expecting differences where time functions are accessed."
	FILE=$$(mktemp -p "$(OUT_DIR)") ; \
		$(LUA) ./test_jgsl.lua >> $$FILE ; \
		echo "$${FILE}" ; \
		diff ./regression_data/test_jgsl.out "$${FILE}"

test_CsvParser:
	mkdir -p "$(OUT_DIR)"
	@echo "This test pipes the output through sort because Lua tables are not sorted."
	FILE=$$(mktemp -p "$(OUT_DIR)") ; \
		$(LUA) ./testsCsvParser.lua | sort >> $$FILE ; \
		echo "$${FILE}" ; \
		diff ./regression_data/testsCsvParser.out "$${FILE}"

test_Scanner:
	mkdir -p "$(OUT_DIR)"
	FILE=$$(mktemp -p "$(OUT_DIR)") ; \
		$(LUA) ./testsScanner.lua >> $$FILE ; \
		echo "$${FILE}" ; \
		diff ./regression_data/testsScanner.out "$${FILE}"

