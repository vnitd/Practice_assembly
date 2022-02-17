export

ifeq ($(BOOTDIR),)
BOOTDIR != pwd
endif

ifeq ($(BOOTBUILDDIR),)
BOOTBUILDDIR := $(BUILDDIR)/boot
endif

BOOTBIN=bootSector.bin \
		secondStage.bin \
		fileTable.bin
$(KERNOBJ:%=$(KERNOBJDIR)/%)

.PHONY: all makebootdir clean
all: \
	makebootdir \
	$(BOOTBIN)

makebootdir:
	@$(MKDIR) $(BOOTBUILDDIR)

%.bin: %.asm
	@$(ECHO) "[ASM   ]" $(BOOTBUILDDIR)/$@
	@$(ASM) -fbin $< -o $(BOOTBUILDDIR)/$@

clean:
	@rm -r $(BOOTBUILDDIR) || true
