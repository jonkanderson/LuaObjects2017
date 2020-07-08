OUTDIR?=../out/lib
BUILDDIR=../out/build
TESTDIR=../tests

LUA=/usr/bin/lua5.3
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
	$(CC) -shared $(LIBSFOR_$*) $(LUALIB) -llua5.3 -o $@ -fPIC $(BUILDDIR)/$*.c

$(BUILDDIR)/%.c: build_%.lua
	mkdir -p $(BUILDDIR)
	$(LUA) $< "$@" ; if [ $$? != 0 ] ; then rm $@ ; fi
