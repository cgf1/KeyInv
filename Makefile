a=/smb/c/Users/cgf/Documents/Elder\ Scrolls\ Online/live/AddOns
.PHONY: all install
all:
	@/usr/src/POC/esolua KeyInv.lua

install: all
	@rsync -ai KeyInv.lua KeyInv.txt Bindings.xml $a/KeyInv
	@touch $a/POC/POC.txt
