##
##

AS = alp.exe
ASFLAGS = +Fl -Mb
LN = link386
LNFLAGS = /inf /map /noi

.SUFFIXES: .asm .obj

.asm.obj:
	$(AS) $(ASFLAGS) $**


ALL:	s9c.exe s9ci.dll

s9c.exe:	s9c.obj
	$(LN) $(LNFLAGS) $*.obj,$@,,,$*.def
	eautil $@ nul /s
	mapsym $*
	lxlite $@

s9ci.dll:	s9ci.obj
	$(LN) $(LNFLAGS) $*.obj,$@,,,$*.def
	eautil $@ nul /s
	mapsym $*
	lxlite $@

clean:
	if exist *.obj  del *.obj
	if exist *.lst  del *.lst
