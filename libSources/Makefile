OUTDIR?=../out/lib
BUILDDIR=../out/build
TESTDIR=../tests

LUA_VERSION=5.4
LUA=/usr/bin/lua$(LUA_VERSION)
CC=/usr/bin/clang

#-------------------------------------------------------------
LIBNAMES=jgsl

.PHONY: all
all: $(patsubst %,test_%,$(LIBNAMES))

.PHONY: clean
clean: $(patsubst %,clean_%,$(LIBNAMES))

#-------------------------------------------------------------

LIBSFOR_jgsl=-lgsl -lgslcblas

#-------------------------------------------------------------

test_%: $(TESTDIR)/test_%.lua
	$(MAKE) "$(OUTDIR)/$*.so"
	#$(LUA) -e "package.cpath = package.cpath..';$(OUTDIR)/?.so'" $<
	$(LUA) $<

clean_%:
	rm -f $(BUILDDIR)/$*.c $(OUTDIR)/$*.so

$(OUTDIR)/%.so:
	$(MAKE) $(BUILDDIR)/$*.c
	mkdir -p $(OUTDIR)
	$(CC) -shared $(LIBSFOR_$*) $(LUALIB) -llua$(LUA_VERSION) -o $@ -fPIC $(BUILDDIR)/$*.c

$(BUILDDIR)/%.c: build_%.lua
	mkdir -p $(BUILDDIR)
	$(LUA) $< "$(LUA_VERSION)" "$@"; if [ $$? != 0 ] ; then rm $@ ; fi
