.PHONY: all
all:

#-------------------------------- Setting preferences
LOCAL_PREFERENCES=local_pref.mk

ifeq "$(wildcard $(LOCAL_PREFERENCES))" "$(LOCAL_PREFERENCES)"
include $(LOCAL_PREFERENCES)
endif

EDITOR?=/usr/bin/geany

#-------------------------------- Useful commands
.PHONY: edit_everything
edit_everything:
	$(EDITOR) $$(find . -not -path "./.git/*" -not -path "./out/*" -type f) &

#-------------------------------- House keeping
.PHONY: pristine
pristine:
	rm -rf out
